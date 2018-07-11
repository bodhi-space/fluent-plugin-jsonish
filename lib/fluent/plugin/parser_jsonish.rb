module Fluent
  class TextParser
    class StdFormatTimeParser < TimeParser

      # Extend the standard TimeParser to be able to use methods for
      # standard formats -- in particular, for formats which can be
      # represented by muliple hard-coded formats.  For instance, the
      # iso8601 format can be represented by either of the following
      # formats (probably more) which are *not* interchangable as
      # arguments to strptime -- whether or not the tiemstamp has
      # millisecond precision must be treated as two distinct formats
      # if the available iso8601 method is not used:
      #
      # * '%y-%m-%dT%H:%M:%S%Z' (no fractional seconds)
      # * '%y-%m-%dT%H:%M:%S.%L%Z' (fractional seconds)

      def initialize(format)

        if not /%/.match(format)
          super()
          @parse = ->(v){ Fluent::EventTime.from_time(Time.method(format).call(v)) }
        else
          super(format)
        end
      end
    end

    class JSONishParser < JSONParser

      Plugin.register_parser('jsonish', self)

      config_param :maps, :array, :default => []
      config_param :null_pattern, :string, :default => '-'
      config_param :null_maps, :array, :default => [
        [ '(:\s+)"%s"(\s*[,}])', '\1null\2' ],
        [ '(:\s+)%s(\s*[,}])', '\1null\2' ],
        [ '(:\s+)\[\s*%s\s*\](\s*[,}])', '\1[]\2' ],
        [ '(:\s+){\s*%s\*}(\s*[,}])', '\1{}\2' ]
      ]
      config_param :message_key, :string, :default => nil
      config_param :add_full_message, :bool, :default => false
      config_param :move_keys, :hash, :default => {}

      def initialize
        super
      end

      def configure(conf)

        if conf['time_format'] and not conf['time_format'].nil?
          # Remove the time_format key before the super call so
          # the it does as little as possible as possible (ie.
          # less that we'll have to override).
          tmp_time_format = conf.delete('time_format')
          # This has to be set to string when time_format is set.
          # Deleting it without deleting time_type will leave an
          # invalid configuration.
          tmp_time_type = conf.delete('time_type')
        end

        super(conf)

        # Overwrite the time parser unless the time_type is set
        # to something other than string.
        if not tmp_time_type.nil? and tmp_time_type == 'string'
            @time_parser = StdFormatTimeParser.new(tmp_time_format)
            # If these values are not restored, fluent will not
            # show the value in trace/debug output.
            conf['time_type'] = tmp_time_type
            @time_type = tmp_time_type
            conf['time_format'] = tmp_time_format
            @time_format = tmp_time_format
        elsif tmp_time_format.nil?
            # The v1.0 time parser has a way to use the Time class
            # method iso8601, but I would still to be able to access
            # any available Time methods in a generic way.
            @time_parser = StdFormatTimeParser.new('iso8601')
            @time_type = 'string'
            @time_format = 'iso8601'
        end
        @mutex = Mutex.new

        @transforms = []

        @maps.each do |elem|
          if elem.is_a?(Array)
            @transforms << [ Regexp.new(elem[0]), elem[1] ]
          elsif elem.is_a?(String)
            if elem == 'slashes'
              @transforms << [ Regexp.new("\\\\"), "\\\\\\" ]
            elsif elem == 'nulls'
              @null_maps.each do |e|
                @transforms << [ Regexp.new(sprintf(e[0],@null_pattern)), e[1] ]
              end
            else
              raise ConfigError, "Unknown transform #{elem}."
            end
          else
            raise ConfigError, "Unknown transform data type."
          end
        end

      end

      def parse(text)

        full_message = @add_full_message ? text : nil

        @transforms.each do |args|
          text.gsub!(*args)
        end

        super(text) do |time,record|
          if @message_key
            record['message'] = record[@message_key]
          end

          if full_message
            record['full_message'] = full_message
          end

          @move_keys.map do |k,v|
            record[v] = record.delete(k)
          end
          record.delete(nil)

          yield time, record
        end

      end

    end
  end
end

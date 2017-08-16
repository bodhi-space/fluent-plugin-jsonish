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

      def initialize(time_format)

        if not time_format.nil? and time_format.empty?
          # Set a reasonable default.
          time_format = 'iso8601'
        end

        if not time_format.nil? and not /%/.match(time_format)
          super(nil)

          @parser = Proc.new { |v| Time.method(time_format).call(v) }

        else
          super(time_format)
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

        if conf['time_format']
          # Remove the time_format key before the super call
          # so the it does as little as possible as possible
          # (ie. less that we'll have to override).
          tmp_time_format = conf['time_format']
          conf.delete('time_format')
        end

        super(conf)

        @time_parser = StdFormatTimeParser.new(tmp_time_format)
        @mutex = Mutex.new

        # This may look stupid (it actually is really stupid),
        # but this *must* be set back to a non-null string
        # prior to the return, since the superclass parser
        # method checks for this and them implements its
        # own ad hoc parser, in-line.  This is a necessary
        # kludge to bypass a more egregious kludge.
        @time_format = 'ignore_me'

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

require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class NodejsBunyanParser < JSONishParser
      Plugin.register_parser('logstash', self)

      def configure(conf)
        super(conf.update({ 'time_key' => '@timestamp'}))
      end

      def parse(text)
        super(text) do |time, record|
          # Cannot be disabled in the library and serves no purpose,
          # since it never varies.
          record.delete('@version')
          # Passing 'message_key' only duplicates the key to 'message' --
          # it does not delete the original key (which is unneeded).
          record.delete(@message_key)
          yield time, record
        end
      end

    end
  end
end

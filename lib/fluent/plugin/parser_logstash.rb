require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class LogstashParser < JSONishParser
      Plugin.register_parser('logstash', self)

      def configure(conf)
        super(conf.update({ 'time_key' => '@timestamp', 'remap_keys' => { '@version' => nil } }))
      end

      def parse(text)
        super(text) do |time, record|
          record.delete('@version')
          unless @message_key.nil? or @message_key == 'message'
            # Passing 'message_key' only duplicates the key to 'message' --
            # it does not delete the original key (which is unneeded).
            record.delete(@message_key) if record.key?(@message_key)
          end
          yield time, record
        end
      end

    end
  end
end

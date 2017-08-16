require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class NodejsLogstash < JSONishParser
      Plugin.register_parser('logstash', self)

      def configure(conf)
        super(conf)
        @time_key = '@timestamp'
        @move_keys.update({ '@version' => nil, '@timestamp' => nil })
      end

    end
  end
end

require_relative 'formatter_jsonish'

module Fluent
  module TextFormatter
    class LogstashFormatter < JSONishFormatter
      Plugin.register_formatter('logstash', self)

      def configure(conf)
        super(conf)
        @add_time = { 'key' => '@timestamp', 'format' => 'iso8601(3)' }
      end

    end
  end
end

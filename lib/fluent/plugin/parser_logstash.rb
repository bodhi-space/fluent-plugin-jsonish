require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class NodejsBunyanParser < JSONishParser
      Plugin.register_parser('nodejs_bunyan', self)

      def configure(conf)
        super(conf)
        @time_key = 'time'
        @message_key = 'msg'
        @move_maps.update({ 'v' => nil, 'msg' => nil, 'hostname' => 'host' })
      end

      def parse(text)
        super(text) do |time, record|
          # Map the developer-defined levels to  syslog levels.
          record['level'] = 8+(record['level']<=30?1:0)-(record['level']/10)
          yield time, record
        end
      end

    end
  end
end

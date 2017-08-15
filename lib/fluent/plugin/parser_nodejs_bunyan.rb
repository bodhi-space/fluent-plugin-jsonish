require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class NodejsBunyanParser < JSONishParser
      Plugin.register_parser('nodejs_bunyan', self)

      def configure(conf)
        super(conf.update({ 'time_key' => 'time', 'message_key' => 'msg', 'remap_keys' => { 'v': nil, 'host' => 'hostname', 'msg' => nil }))
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

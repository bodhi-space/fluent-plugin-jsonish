require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class NodejsBunyanParser < JSONishParser
      Plugin.register_parser('nodejs_bunyan', self)

      def configure(conf)
        super(conf.update({ 'time_key' => 'time', 'message_key' => 'msg'}))
      end

      def parse(text)
        super(text) do |time, record|
          record['level'] = 8+(record['level']<=30?1:0)-(record['level']/10)
          record.delete('v')
          record.delete('hostname')
          record.delete(@message_key)
          yield time, record
        end
      end

    end
  end
end


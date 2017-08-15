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
          # Map the developer-defined levels to  syslog levels.
          record['level'] = 8+(record['level']<=30?1:0)-(record['level']/10)
          # Cannot be disabled in the library and serves no purpose,
          # since it never varies.
          record.delete('v')
          # Fluent expects the host to be keyed with 'host', not 'hostname'.
          record['host'] = record.delete('hostname')
          record.delete('hostname')
          # Passing 'message_key' only duplicates the key to 'message' --
          # it does not delete the original key (which is unneeded).
          record.delete(@message_key)
          yield time, record
        end
      end

    end
  end
end

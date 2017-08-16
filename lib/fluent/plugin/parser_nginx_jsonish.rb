require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class NginxJSONishParser < JSONishParser
      Plugin.register_parser('nginx_jsonish', self)


      def configure(conf)

        if conf.key?('maps')
          conf['maps'] = ([ 'slashes', 'nulls' ] + JSON.parse(conf['maps'])).uniq.to_json
        else
          conf['maps'] = [ 'slashes', 'nulls' ].to_json
        end

        super(conf)

        if @message_key.nil? or @message_key.empty?
          @message_key = 'request'
        end

      end

    end
  end
end

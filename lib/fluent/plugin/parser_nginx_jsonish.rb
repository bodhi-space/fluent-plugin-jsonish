require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class NginxJSONishParser < JSONishParser
      Plugin.register_parser('nginx_jsonish', self)


      def configure(conf)

        if conf['maps'].is_a?(Array)
          conf['maps'] = ([ 'slashes', 'nulls' ] + conf['maps']).uniq
        else
          conf['maps'] = [ 'slashes', 'nulls' ]
        end

        if not (conf['message_key'] and conf['message_key'].is_empty?)
          conf['message_key']  = 'request'
        end

        super(conf)

      end

    end
  end
end

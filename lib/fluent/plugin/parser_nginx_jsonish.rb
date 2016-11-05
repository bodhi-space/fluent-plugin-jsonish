require_relative 'parser_jsonish'

module Fluent
  class TextParser
    class NginxJSONishParser < JSONishParser
      Plugin.register_parser('nginx_jsonish', self)


      def configure(conf)
        #wtf = { 'message_key' => 'request', 'maps' => '[ "slashes", "nulls" ]' }.update(conf)

        if conf['maps'].is_a?(Array)
          conf['maps'] = ([ 'slashes', 'nulls' ] + conf['maps']).uniq
        else
          conf['maps'] = [ 'slashes', 'nulls' ]
        end

        if not (conf['message_key'] and conf['message'].is_empty?)
          conf['message_key']  = 'request'
        end

        super(conf)

      end

        # WTF?
#        super
#        @message_key ||= 'request'
#        if @maps.empty?
#          conf['maps'] = [ 'slashes', 'nulls' ].to_json
#        else
#          conf['maps'] = (['slashes', 'nulls'] + JSON.parse(conf['maps']).uniq).to_json
#        end
#        if conf['maps'] 
#          conf['maps'] = (['slashes', 'nulls'] + JSON.parse(conf['maps']).uniq).to_json
#        else
#          conf['maps'] = [ 'slashes', 'nulls' ].to_json
#        end
#
#        if not conf['message_key'] 
#          conf['message_key'] = 'request'
#        end
#
#        super(conf)

    end
  end
end


require "./connections"

module Rockethook
  module Server
    class Deliverer
      USER_AGENT = "Rockethook/#{Rockethook::VERSION}"
      CONTENT_TYPE = "application/json"
      KEEP_ALIVE = "timeout=15, max=100"

      getter webhook : Rockethook::Webhook
      getter connections : Rockethook::Server::Connections
      getter uri : URI

      def initialize(@webhook : Rockethook::Webhook, @connections : Rockethook::Server::Connections)
        @uri = URI.parse(webhook.uri)
      end

      def post
        response = connections[@uri].client do |client|
          client.post(uri.path.to_s, headers: headers, body: body)
        end
        response.success?
      end

      def headers
        HTTP::Headers{ "User-Agent" => USER_AGENT,
                       "Content-Type" => CONTENT_TYPE,
                       "Keep-Alive" => KEEP_ALIVE,
                       "X-Webhook-Context" => webhook.context,
                       "X-Webhook-Signature" => webhook.generate_hmac,
                       "X-Webhook-Event" => webhook.event }
      end

      def body
        webhook.payload.to_json
      end
    end
  end
end

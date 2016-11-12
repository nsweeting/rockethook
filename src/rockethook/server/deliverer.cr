require "./connections"

module Rockethook
  module Server
    class Deliverer
      BASE_HEADER = { "User-Agent" => "Rockethook/#{Rockethook::VERSION}",
                      "Content-Type" => "application/json",
                      "Keep-Alive" => "timeout=15, max=100" }

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
        HTTP::Headers{ "X-Webhook-Context" => webhook.context,
                       "X-Webhook-Signature" => webhook.generate_hmac,
                       "X-Webhook-Event" => webhook.event }.merge!(BASE_HEADER)
      end

      def body
        webhook.payload.to_json
      end
    end
  end
end

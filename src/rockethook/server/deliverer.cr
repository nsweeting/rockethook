module Rockethook
  module Server
    class Deliverer
      def initialize(@manager : Rockethook::Server::Manager)
      end

      def start
        spawn do
          until stop
            hook = fetch_hook
            post(hook) if hook
          end
        end
      end

      def fetch_hook
        @manager.fetcher.pop_one
      end

      def post(hook : Rockethook::Webhook)
        response = HTTP::Client.post(hook.uri, hook.headers, body: hook.payload)
        response.success? ? success! : failure!(hook)
      rescue
        failure!(hook)
      end

      private def success!
        @manager.stats.success!
      end

      private def failure!(hook : Rockethook::Webhook)
        hook.bump_attempts
        @manager.stats.failure!
        @manager.delayer.add_one(hook)
      end

      private def stop
        @manager.stop?
      end
    end
  end
end

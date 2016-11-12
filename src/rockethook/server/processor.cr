require "./deliverer"

module Rockethook
  module Server
    class Processor
      def initialize(@manager : Rockethook::Server::Manager)
      end

      def start
        spawn do
          until stop
            hook = fetch_hook
            deliver(hook) if hook
          end
        end
      end

      def fetch_hook
        @manager.fetcher.pop_one
      end

      def deliver(hook : Rockethook::Webhook)
        deliverer = Rockethook::Server::Deliverer.new(hook, connections)
        response = deliverer.post
        response ? success! : failure!(hook)
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

      private def connections
        @manager.connections
      end
    end
  end
end

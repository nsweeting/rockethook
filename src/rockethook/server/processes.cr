module Rockethook
  module Server
    module Process
      def initialize(@manager : Rockethook::Server::Manager)
      end

      def start
        spawn do
          until stop
            execute
          end
        end
      end

      private def connections
        @manager.connections
      end

      private def fetcher
        @manager.fetcher
      end

      private def delayer
        @manager.delayer
      end

      private def poller
        @manager.poller
      end

      private def stats
        @manager.stats
      end

      private def stop
        @manager.stop?
      end
    end

    class Tracker
      include Process

      SLEEP = 5

      def execute
        stats.update
        sleep SLEEP
      end
    end

    class Scheduler
      include Process

      def execute
        poller.call
        sleep (15 * rand) + (15.to_f / 2)
      end
    end

    class Reaper
      include Process

      SLEEP = 60

      def execute
        connections.delete_old!
        sleep SLEEP
      end
    end

    class Deliverer
      include Process

      HEADER = {
        "User-Agent" => "Rockethook/#{Rockethook::VERSION}",
        "Content-Type" => "application/json",
        "Keep-Alive" => "timeout=15, max=100"
      }

      def execute
        webhhook = fetcher.call
        deliver(webhhook) if webhhook
      end

      private def deliver(webhook : Rockethook::Webhook)
        uri = URI.parse(webhook.uri)
        response = connections[uri].client do |client|
          client.post(uri.path.to_s, headers: webhook.headers.merge!(HEADER),
                                     body: webhook.payload.to_json)
        end
        response.success? ? success! : failure!(webhook)
      end

      private def success!
        stats.success!
      end

      private def failure!(webhook : Rockethook::Webhook)
        webhook.bump_attempts
        stats.failure!
        delayer.call(webhook)
      end
    end
  end
end

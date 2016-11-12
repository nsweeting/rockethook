module Rockethook
  module Server
    class Process
      def initialize(@manager : Rockethook::Server::Manager)
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

    class Tracker < Process
      SLEEP = 5

      def start
        spawn do
          until stop
            stats.update
            sleep SLEEP
          end
        end
      end
    end

    class Scheduler < Process
      def start
        spawn do
          until stop
            poller.requeue
            wait
          end
        end
      end

      private def wait
        sleep(random_poll_interval)
      end

      private def random_poll_interval
        (15 * rand) + (15.to_f / 2)
      end
    end

    class Reaper < Process
      SLEEP = 60

      def start
        spawn do
          until stop
            connections.delete_old!
            sleep SLEEP
          end
        end
      end
    end

    class Deliverer < Process
      HEADER = {
        "User-Agent" => "Rockethook/#{Rockethook::VERSION}",
        "Content-Type" => "application/json",
        "Keep-Alive" => "timeout=15, max=100"
      }

      def start
        spawn do
          until stop
            webhhook = fetcher.pop
            deliver(webhhook) if webhhook
          end
        end
      end

      def deliver(webhook : Rockethook::Webhook)
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
        delayer.add(webhook)
      end
    end
  end
end

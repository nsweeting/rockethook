module Rockethook
  module Server
    class Scheduler
      def initialize(@manager : Rockethook::Server::Manager)
      end

      def start
        spawn do
          until stop
            run_poller
            wait
          end
        end
      end

      def run_poller
        @manager.poller.requeue
      end

      private def wait
        sleep(random_poll_interval)
      end

      private def random_poll_interval
        (15 * rand) + (15.to_f / 2)
      end

      private def stop
        @manager.stop?
      end
    end
  end
end

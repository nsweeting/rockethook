module Rockethook
  module Server
    class Tracker
      INTERVAL = 5

      property interval : Int32

      def initialize(@manager : Rockethook::Server::Manager)
        @interval = INTERVAL
      end

      def start
        spawn do
          until stop
            puts "success: #{@manager.stats.success}, failure: #{@manager.stats.failure}"
            sleep interval
          end
        end
      end

      private def stop
        @manager.stop?
      end
    end
  end
end

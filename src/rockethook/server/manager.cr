module Rockethook
  module Server
    class Manager
      getter cxt : Rockethook::Context
      getter concurrency : Int32
      getter deliverers : Array(Deliverer)
      getter schedulers : Array(Scheduler)
      getter trackers : Array(Tracker)
      getter fetcher : Rockethook::Server::Fetcher
      getter delayer : Rockethook::Server::Delayer
      getter poller : Rockethook::Server::Poller
      getter stats : Rockethook::Server::Statistics

      def initialize(@cxt : Rockethook::Context)
        @concurrency  = cxt.config.concurrency
        @trackers     = [] of Rockethook::Server::Tracker
        @deliverers   = [] of Rockethook::Server::Deliverer
        @schedulers   = [] of Rockethook::Server::Scheduler
        @fetcher      = Rockethook::Server::Fetcher.new(cxt)
        @delayer      = Rockethook::Server::Delayer.new(cxt)
        @poller       = Rockethook::Server::Poller.new(cxt)
        @stats        = Rockethook::Server::Statistics.new(cxt)
      end

      def start
        start_trackers
        start_deliverers
        start_scheduler
      end

      def start_trackers
        tracker = Rockethook::Server::Tracker.new(self)
        @trackers << tracker
        tracker.start
      end

      def start_deliverers
        concurrency.times do
          deliverer = Rockethook::Server::Deliverer.new(self)
          @deliverers << deliverer
          deliverer.start
        end
      end

      def start_scheduler
        scheduler = Rockethook::Server::Scheduler.new(self)
        @schedulers << scheduler
        scheduler.start
      end

      def stop!
        @stop = true
      end

      def stop?
        @stop
      end
    end
  end
end

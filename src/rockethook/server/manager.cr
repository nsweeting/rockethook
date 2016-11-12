require "../webhook"
require "../client"
require "./processor"
require "./scheduler"
require "./tracker"
require "./fetcher"
require "./delayer"
require "./poller"
require "./statistics"
require "./connections"

module Rockethook
  module Server
    class Manager
      getter cxt : Rockethook::Context
      getter concurrency : Int32
      getter processors : Array(Processor)
      getter schedulers : Array(Scheduler)
      getter trackers : Array(Tracker)
      getter connections : Rockethook::Server::Connections
      getter fetcher : Rockethook::Server::Fetcher
      getter delayer : Rockethook::Server::Delayer
      getter poller : Rockethook::Server::Poller
      getter stats : Rockethook::Server::Statistics

      def initialize(@cxt : Rockethook::Context)
        @concurrency  = cxt.config.concurrency
        @trackers     = [] of Rockethook::Server::Tracker
        @processors   = [] of Rockethook::Server::Processor
        @schedulers   = [] of Rockethook::Server::Scheduler
        @collectors   = [] of Rockethook::Server::ConnectionCollector
        @connections  = Rockethook::Server::Connections.new(cxt)
        @fetcher      = Rockethook::Server::Fetcher.new(cxt)
        @delayer      = Rockethook::Server::Delayer.new(cxt)
        @poller       = Rockethook::Server::Poller.new(cxt)
        @stats        = Rockethook::Server::Statistics.new(cxt)

      end

      def start
        start_collectors
        start_trackers
        start_processors
        start_scheduler
      end

      def start_collectors
        collector = Rockethook::Server::ConnectionCollector.new(self)
        @collectors << collector
        collector.start
      end

      def start_trackers
        tracker = Rockethook::Server::Tracker.new(self)
        @trackers << tracker
        tracker.start
      end

      def start_processors
        concurrency.times do
          processor = Rockethook::Server::Processor.new(self)
          @processors << processor
          processor.start
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

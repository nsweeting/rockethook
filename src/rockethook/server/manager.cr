require "../webhook"
require "../client"
require "./processes"
require "./utilities"
require "./connections"

module Rockethook
  module Server
    class Manager
      getter cxt : Rockethook::Context
      getter concurrency : Int32
      getter processes : Array(Processes)
      getter connections : Connections
      getter fetcher : Fetcher
      getter delayer : Delayer
      getter poller : Poller
      getter stats : Statistics

      def initialize(@cxt : Rockethook::Context)
        @concurrency  = cxt.config.concurrency
        @processes    = [] of Processes
        @connections  = Connections.new(cxt)
        @fetcher      = Fetcher.new(cxt)
        @delayer      = Delayer.new(cxt)
        @poller       = Poller.new(cxt)
        @stats        = Statistics.new(cxt)
      end

      def start
        concurrency.times { @processes << Deliverer.new(self) }
        [Reaper.new(self), Tracker.new(self), Scheduler.new(self)].each do |p|
          @processes << p
        end
        @processes.each(&.start)
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

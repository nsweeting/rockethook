module Rockethook
  class Manager
    getter cxt : Context
    getter concurrency : Int32
    getter deliverers : Array(Deliverer)
    getter schedulers : Array(Scheduler)
    getter fetcher : Fetcher
    getter delayer : Delayer
    getter poller : Poller

    def initialize(@cxt : Context)
      @concurrency  = cxt.config.concurrency
      @deliverers   = [] of Deliverer
      @schedulers   = [] of Scheduler
      @fetcher      = Fetcher.new(cxt)
      @delayer      = Delayer.new(cxt)
      @poller       = Poller.new(cxt)
    end

    def start
      start_deliverers
      start_scheduler
    end

    def start_deliverers
      concurrency.times do
        deliverer = Deliverer.new(self)
        @deliverers << deliverer
        deliverer.start
      end
    end

    def start_scheduler
      scheduler = Scheduler.new(self)
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

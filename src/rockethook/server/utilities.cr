module Rockethook
  module Server
    class Fetcher
      TIMEOUT = 2
      QUEUE = "queue"

      getter queue : Array(String)

      def initialize(@cxt : Rockethook::Context)
        @queue = ["#{cxt.config.full_namespace}:#{QUEUE}"]
      end

      def call
        array = @cxt.redis do |conn|
          conn.brpop(queue, TIMEOUT).as(Array(Redis::RedisValue))
        end
        Webhook.from_json(array.last.to_s) if array.size == 2
      end
    end

    class Delayer
      QUEUE = "retry"

      getter queue : String

      def initialize(@cxt : Rockethook::Context)
        @queue = "#{@cxt.config.full_namespace}:#{QUEUE}"
      end

      def call(webhook : Rockethook::Webhook)
        return if webhook.attempts > @cxt.config.max_attempts
        delay = Time.now + delay_for(webhook.attempts).seconds
        @cxt.redis { |conn| conn.zadd(queue, delay.epoch, webhook.to_json) }
      end

      private def delay_for(count)
        @cxt.config.retry_schedule[count - 1]? || default_delay(count)
      end

      private def default_delay(count)
        (count ** 4) + 15 + (rand(30)*(count + 1))
      end
    end

    class Poller
      QUEUE = "retry"

      getter queue : String

      def initialize(@cxt : Rockethook::Context)
        @queue = "#{@cxt.config.full_namespace}:#{QUEUE}"
        @client = Rockethook::Client.new(@cxt)
      end

      def call(time = Time.now.epoch)
        @cxt.redis do |conn|
          loop do
            results = conn.zrangebyscore(queue, "-inf", time, limit: [0, 1]).as(Array)
            break if results.empty?
            hookstr = results[0].as(String)
            @client.push(hookstr) if conn.zrem(queue, hookstr)
          end
        end
      end
    end

    class Statistics
      getter success : Int32
      getter failure : Int32
      getter start : Int32 | Int64

      def initialize(@cxt : Rockethook::Context)
        @success   = 0
        @failure   = 0
        @start     = Time.now.epoch
      end

      def update
        @cxt.logger.info("Success: #{success}, Failure: #{failure}")
      end

      def success!
        @success += 1
      end

      def failure!
        @failure += 1
      end
    end
  end
end

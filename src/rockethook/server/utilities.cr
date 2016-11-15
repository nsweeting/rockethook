module Rockethook
  module Server
    class Fetcher
      TIMEOUT = 2
      QUEUE = "queue"

      getter queue : Array(String)

      def initialize(@cxt : Rockethook::Context)
        @queue = ["#{cxt.config.full_namespace}:#{QUEUE}"]
      end

      def pop
        array = @cxt.pool.redis do |conn|
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

      def add(webhook : Rockethook::Webhook)
        return if max_attempts?(webhook)
        delay = Time.now + delay_for(webhook.attempts).seconds
        @cxt.pool.redis { |conn| conn.zadd(queue, delay.epoch, webhook.to_json) }
      end

      private def delay_for(count)
        @cxt.config.retry_schedule[count - 1]? || default_delay(count)
      end

      private def max_attempts?(webhook : Rockethook::Webhook)
        webhook.attempts > @cxt.config.max_attempts
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

      def requeue
        now = Time.now.epoch
        @cxt.pool.redis do |conn|
          loop do
            results = conn.zrangebyscore(queue, "-inf", now, limit: [0, 1]).as(Array)
            break if results.empty?
            hookstr = results[0].as(String)
            @client.push(hookstr) if conn.zrem(queue, hookstr)
          end
        end
      end
    end
  end
end

module Rockethook
  module Server
    class Delayer
      QUEUE = "retry"

      getter queue : String

      def initialize(@cxt : Rockethook::Context)
        @queue = "#{@cxt.config.full_namespace}:#{QUEUE}"
      end

      def add(webhook : Rockethook::Webhook)
        return if max_attempts(webhook)
        delay = Time.now + delay_for(webhook.attempts).seconds
        @cxt.pool.redis { |conn| conn.zadd(queue, delay.epoch, webhook.to_json) }
      end

      def delay_for(count)
        @cxt.config.retry_schedule[count - 1]? || default_delay(count)
      end

      def max_attempts(webhook : Rockethook::Webhook)
        webhook.attempts > @cxt.config.max_attempts
      end

      def default_delay(count)
        (count ** 4) + 15 + (rand(30)*(count + 1))
      end
    end
  end
end

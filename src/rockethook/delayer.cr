module Rockethook
  class Delayer
    QUEUE = "retry"

    getter queue : String

    def initialize(@cxt : Context)
      @queue = "#{@cxt.config.full_namespace}:#{QUEUE}"
    end

    def add_one(hook : Webhook)
      return if max_attempts(hook)
      delay = Time.now + delay_for(hook.attempts).seconds
      @cxt.pool.redis { |conn| conn.zadd(queue, delay.epoch, hook.to_json) }
    end

    def delay_for(count)
      @cxt.config.retry_schedule[count - 1]
    end

    def max_attempts(hook : Webhook)
      hook.attempts > @cxt.config.max_attempts
    end
  end
end

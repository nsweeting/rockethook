module Rockethook
  class Client
    QUEUE = "queue"

    getter queue : String

    def initialize(@cxt : Context)
      @queue = "#{@cxt.config.full_namespace}:#{QUEUE}"
    end

    def push_one(hook : String)
      @cxt.pool.redis { |conn| conn.lpush(queue, hook) }
    end

    def push_one(hook : Webhook)
      @cxt.pool.redis { |conn| conn.lpush(queue, hook.to_json) }
    end
  end
end

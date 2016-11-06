module Rockethook
  class Poller
    QUEUE = "retry"

    getter queue : String

    def initialize(@cxt : Context)
      @queue = "#{@cxt.config.full_namespace}:#{QUEUE}"
      @client = Client.new(@cxt)
    end

    def requeue
      now = Time.now.epoch
      @cxt.pool.redis do |conn|
        loop do
          results = conn.zrangebyscore(queue, "-inf", now, limit: [0, 1]).as(Array)
          break if results.empty?
          hookstr = results[0].as(String)
          @client.push_one(hookstr) if conn.zrem(queue, hookstr)
        end
      end
    end
  end
end

module Rockethook
  module Server
    class Fetcher
      TIMEOUT = 2
      QUEUE = "queue"

      getter queue : Array(String)

      def initialize(@cxt : Rockethook::Context)
        @queue = ["#{cxt.config.full_namespace}:#{QUEUE}"]
      end

      def pop_one
        array = @cxt.pool.redis do |conn|
          conn.brpop(queue, TIMEOUT).as(Array(Redis::RedisValue))
        end
        Webhook.from_json(array.last.to_s) if array.size == 2
      rescue JSON::ParseException
        return nil
      end
    end
  end
end

module Rockethook
  class Context
    property config : Config
    property pool : RedisPool

    def initialize(@config : Config)
      @pool = RedisPool.new(size: @config.redis_pool, timeout: @config.redis_timeout)
    end
  end
end

module Rockethook
  class Context
    property config : Config
    property pool : RedisPool
    property logger : ::Logger

    def initialize(@config : Config)
      @pool = RedisPool.new(size: @config.redis_pool, timeout: @config.redis_timeout)
      @logger = ::Logger.new(STDOUT)
    end
  end
end

require "uri"
require "redis"
require "pool/connection"

module Rockethook
  class RedisConfig
    property! host : String
    property! port : Int32
    property! db : Int32
    property password : String?

    def initialize(@host = "localhost", @port = 6379, @db = 0, @password = nil)
      return unless ENV["REDIS_PROVIDER"]?
      redis_url   = URI.parse(ENV[ENV["REDIS_PROVIDER"]])
      @host       = redis_url.host.not_nil!
      @port       = redis_url.port
      @password   = redis_url.password
      @db         = db_from_path(redis_url.path)
    end

    def new_client
      Redis.new(host: host, port: port, password: password, database: db)
    end

    private def db_from_path(path)
      return @db unless path.is_a?(String)
      return @db unless path.size > 1
      path.as(String)[1..-1].to_i
    end
  end

  class RedisPool
    property! config : RedisConfig
    property! size : Int32
    property! timeout : Float64
    property pool : ConnectionPool(Redis)

    def initialize(@size = 5, @timeout = 5.0, @config = RedisConfig.new)
      @pool = build_pool
    end

    def redis
      pool.connection { |conn| yield conn }
    end

    def redis_pipe
      pool.connection do |conn|
        conn.pipelined { |pipe| yield pipe }
      end
    end

    private def build_pool
      ConnectionPool(Redis).new(capacity: size, timeout: timeout) do
        config.new_client
      end
    end
  end
end

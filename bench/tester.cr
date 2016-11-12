require "redis"
require "http"
require "kemal"
require "pool/connection"

logging false
post "/" { "test" }
spawn { Kemal.run }

total = 100_000
redis = Redis.new
total.times { redis.lpush("testqueue", "test") }

posters = [] of Poster
5.times do
  poster = Poster.new
  posters << poster
  poster.start
end

sleep

class Poster
  def start
    spawn do
      redis = Redis.new
      uri = URI.parse("http://localhost:3000/")
      pool = ConnectionPool(HTTP::Client).new(capacity: 5, timeout: 5.0) do
        HTTP::Client.new(uri)
      end
      loop do
        pop = redis.brpop(["testqueue"], 2).as(Array(Redis::RedisValue))
        next unless pop.size == 2
        response = pool.connection { |c| c.post(uri.path.to_s) }
        puts response.success?
      end
    end
  end
end

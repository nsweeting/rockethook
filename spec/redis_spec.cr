require "./spec_helper"
require "../src/rockethook/redis"

describe Rockethook::RedisConfig do
  it "can create a Redis instance" do
    redis_config = Rockethook::RedisConfig.new
    redis = redis_config.new_client
    redis.ping.should eq "PONG"
  end

  it "can create a Redis instance using config from ENV" do
    ENV["REDIS_PROVIDER"] = "REDIS_URL"
    ENV["REDIS_URL"] = "redis://localhost:6379/1"
    redis_config = Rockethook::RedisConfig.new
    redis_config.db.should eq 1
    redis = redis_config.new_client
    redis.ping.should eq "PONG"
  end
end

describe Rockethook::RedisPool do
  it "can create a usable Redis connection pool" do
    config = Rockethook::RedisConfig.new
    pool = Rockethook::RedisPool.new(size: 5, timeout: 5.0, config: config)
    pool.size.should eq 5
    pool.timeout.should eq 5.0
    pool.redis { |conn| conn.ping.should eq "PONG" }
  end

  it "can create a usable Redis connection pool with pipelining" do
    config = Rockethook::RedisConfig.new
    pool = Rockethook::RedisPool.new(size: 5, timeout: 5.0, config: config)
    pool.redis_pipe { |conn| conn.ping }.should eq ["PONG"]
  end
end

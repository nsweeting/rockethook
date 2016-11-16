require "spec"
require "../src/rockethook/config"

Spec.before_each do
  config = Rockethook::RedisConfig.new
  redis = config.new_client
  redis.flushdb
end

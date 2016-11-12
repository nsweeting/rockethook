require "kemal"
require "colorize"
require "../src/rockethook/server/cli"

# This benchmark is an integration test which creates and
# executes 100,000 localhost webhooks through Rockethook. This is
# useful for determining job overhead and raw throughput
# on different platforms.
#
# Requirements:
#  - Redis running on localhost:6379
#  - `shards install`
#  - `crystal run --release bench/benchmark.cr
#

# Starts a Kemal server running on localhost:5000
logging false
Kemal.config.port = 5000
post "/" { "Hello World!" }
spawn { Kemal.run }

# Sets up required Rockethook objects to run our benchmark
redis = Redis.new
server = Rockethook::Server::CLI.new
config = Rockethook::Config.from_yaml("nothing: here")
context = Rockethook::Context.new(config)
client = Rockethook::Client.new(context)

# Creates 100_000 webhooks, and, using the Rockethook Client, pushes them
# into our redis queue.
iter = 10
count = 10_000
total = iter * count
start = Time.now
iter.times do
  webhooks = [] of Rockethook::Webhook
  count.times do |x|
    webhooks << Rockethook::Webhook.from_json(%Q({"uri": "http://localhost:5000/", "payload": {"id": #{x}}}))
  end
  client.push(webhooks)
end
puts "Created #{count*iter} webhooks in #{Time.now - start}".colorize(:green)

# Checks when our queue is empty.
spawn do
  start = Time.now
  loop do
    count = redis.llen("development:webhooks:queue")
    if count == 0
      finish = Time.now
      puts "Done in #{finish - start}: #{"%.3f" % (total / (finish - start).to_f)} jobs/sec".colorize(:green)
      exit
    end
    sleep 0.2
  end
end

# Start the Rockethook server!
server.start

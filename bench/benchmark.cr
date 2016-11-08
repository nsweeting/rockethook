require "../src/rockethook/server/cli"
require "colorize"

redis = Redis.new
server = Rockethook::Server::CLI.new
config = Rockethook::Config.from_yaml("nothing: here")
context = Rockethook::Context.new(config)
client = Rockethook::Client.new(context)

def Process.rss
  `ps -o rss= -p #{Process.pid}`.chomp.to_i
end

iter = 10
count = 10_000
total = iter * count

a = Time.now
iter.times do
  webhooks = [] of Rockethook::Webhook
  count.times do |x|
    webhooks << Rockethook::Webhook.from_json(%Q({"uri": "http://0.0.0.0:3000/", "payload": {"id": #{x}}}))
  end
  client.push_bulk(webhooks)
end
puts "Created #{count*iter} webhooks in #{Time.now - a}"

spawn do
  a = Time.now
  loop do
    count = redis.llen("development:webhooks:queue")
    if count == 0
      b = Time.now
      puts "Done in #{b - a}: #{"%.3f" % (total / (b - a).to_f)} jobs/sec".colorize(:green)
      exit
    end
    p [Time.now, count, Process.rss]
    sleep 2
  end
end

server.start

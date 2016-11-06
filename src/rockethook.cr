require "pool/connection"
require "redis"
require "uri"
require "openssl/hmac"
require "json"
require "http"
require "yaml"
require "option_parser"
require "secure_random"
require "logger"

require "./rockethook/version"
require "./rockethook/config"
require "./rockethook/redis"
require "./rockethook/webhook"
require "./rockethook/client"
require "./rockethook/context"
require "./rockethook/server/cli"
require "./rockethook/server/delayer"
require "./rockethook/server/fetcher"
require "./rockethook/server/poller"
require "./rockethook/server/deliverer"
require "./rockethook/server/scheduler"
require "./rockethook/server/statistics"
require "./rockethook/server/tracker"
require "./rockethook/server/manager"


module Rockethook
  config = Config.from_yaml("nothing: here")
  context = Context.new(config)
  client = Client.new(context)
  webhooks = [] of Webhook
  1..30000.times do |x|
    webhooks << Webhook.from_json(%Q({"uri": "http://0.0.0.0:5000/test", "payload": {"id": #{x}}}))
  end

  client.push_bulk(webhooks)

  cli = Rockethook::Server::CLI.new
  cli.start
end

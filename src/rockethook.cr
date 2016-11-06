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
require "./rockethook/cli"
require "./rockethook/client"
require "./rockethook/delayer"
require "./rockethook/fetcher"
require "./rockethook/poller"
require "./rockethook/deliverer"
require "./rockethook/scheduler"
require "./rockethook/manager"
require "./rockethook/webhook"
require "./rockethook/logger"

module Rockethook
  #config = Config.from_yaml("nothing: here")
  #context = Context.new(config)
  #client = Client.new(context)
  #1..10000.times do
    #webhook = Webhook.from_json("{}")
    #client.push_one(webhook)
  #end

  cli = CLI.new
  cli.start
end

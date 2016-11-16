require "../spec_helper"
require "../../src/rockethook/config"
require "../../src/rockethook/context"
require "../../src/rockethook/client"
require "../../src/rockethook/webhook"
require "../../src/rockethook/server/utilities"

describe Rockethook::Server::Fetcher do
  it "fetches one webhook from Redis" do
    webhook_one = new_webhook
    context = new_context
    push_webhook(context, webhook_one)

    fetcher = Rockethook::Server::Fetcher.new(context)
    webhook_two = fetcher.call

    webhook_one.should eq webhook_two
  end
end

describe Rockethook::Server::Delayer do
  it "schedules one webhook in Redis" do
    webhook_one = new_webhook
    context = new_context

    # Adds a 'failed' webhook to the retry queue
    webhook_one.attempts = 5
    delayer = Rockethook::Server::Delayer.new(context)
    delayer.call(webhook_one)

    # Removes the 'failed' webhook and adds it the the queue
    poller = Rockethook::Server::Poller.new(context)
    poller.call((Time.now + 1.year).epoch)

    # Pops the webhook
    fetcher = Rockethook::Server::Fetcher.new(context)
    webhook_two = fetcher.call

    webhook_one.should eq webhook_two
  end
end

def new_context
  config = Rockethook::Config.from_yaml("nothing: here")
  Rockethook::Context.new(config)
end

def push_webhook(context, webhook)
  client = Rockethook::Client.new(context)
  client.push(webhook)
end

def new_webhook
  Rockethook::Webhook.from_json(%Q({"uri": "http://localhost:5000/", "payload": {"id": 1}}))
end

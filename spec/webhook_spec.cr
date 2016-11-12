require "./spec_helper"
require "../src/rockethook/webhook"

describe Rockethook::Webhook do
  it "responds to from_json" do
    Rockethook::Webhook.from_json("{}")
  end

  it "responds to to_json" do
    webhook = Rockethook::Webhook.from_json("{}")
    webhook.to_json
  end

  it "allows you to set the context" do
    webhook = Rockethook::Webhook.from_json("{\"context\":\"username\"}")
    webhook.context.should eq "username"
  end

  it "allows you to set the uri" do
    webhook = Rockethook::Webhook.from_json("{\"uri\":\"http://localhost:5000\"}")
    webhook.uri.should eq "http://localhost:5000"
  end

  it "allows you to set the token" do
    webhook = Rockethook::Webhook.from_json("{\"token\":\"token\"}")
    webhook.token.should eq "token"
  end

  it "allows you to set the event" do
    webhook = Rockethook::Webhook.from_json("{\"event\":\"user/updated\"}")
    webhook.event.should eq "user/updated"
  end

  it "allows you to set the payload" do
    webhook = Rockethook::Webhook.from_json(%Q({"payload": {"id": 1}}))
    #webhook.payload.should eq {"id"=> 1}
  end

  it "allows you to set the creation" do
    webhook = Rockethook::Webhook.from_json("{\"created\": 1}")
    webhook.created.should eq 1
  end

  it "allows you to set the attempts" do
    webhook = Rockethook::Webhook.from_json("{\"attempts\": 1}")
    webhook.attempts.should eq 1
  end

  it "allows you to bump the attemots" do
    webhook = Rockethook::Webhook.from_json("{\"attempts\": 1}")
    webhook.attempts.should eq 1
    webhook.bump_attempts
    webhook.attempts.should eq 2
  end

  it "has default values set" do
    webhook = Rockethook::Webhook.from_json("{}")
    webhook.created.should eq Time.now.epoch
    webhook.uuid.should be_a(String)
    webhook.context.should eq ""
    webhook.uri.should eq ""
    webhook.token.should eq ""
    webhook.context.should eq ""
    webhook.attempts.should eq 0
  end

  it "can build an hmac token for authentication" do
    webhook = Rockethook::Webhook.from_json(%Q({"token": "token", "payload": {"id": 1}}))
    hmac = Base64.encode(OpenSSL::HMAC.digest(:sha256, "token", { "id" => 1 }.to_json)).strip
    webhook.generate_hmac.should eq hmac
  end

  it "can build HTTP headers" do
    webhook = Rockethook::Webhook.from_json(%Q({"token": "token", "context":"username", "event": "test", "payload": {"id": 1}}))
    hmac = Base64.encode(OpenSSL::HMAC.digest(:sha256, "token", { "id" => 1 }.to_json)).strip
    header = webhook.headers
    header["X-Webhook-Context"].should eq "username"
    header["X-Webhook-Signature"].should eq hmac
    header["X-Webhook-Event"].should eq "test"
  end
end

require "./spec_helper"
require "../src/rockethook/config"

describe Rockethook::Config do
  it "can set the redis pool from yaml" do
    config = load_config
    config.redis_pool.should eq 2
  end

  it "can set the redis timeout from yaml" do
    config = load_config
    config.redis_timeout.should eq 3.0
  end

  it "can set the concurrency from yaml" do
    config = load_config
    config.concurrency.should eq 2
  end

  it "can set logging from yaml" do
    config = load_config
    config.logging.should eq false
  end

  it "can set the max attempts from yaml" do
    config = load_config
    config.max_attempts.should eq 4
  end

  it "can set the retry schedule from yaml" do
    config = load_config
    config.retry_schedule.should eq [60,3600,6400,12800]
  end

  it "can set the pinger from yaml" do
    config = load_config
    config.pinger.should eq true
  end

  it "can set the namespace from yaml" do
    config = load_config
    config.namespace.should eq "test"
  end

  it "can set the environment from yaml" do
    config = load_config
    config.environment.should eq "test"
  end

  it "can set the reaper time from yaml" do
    config = load_config
    config.reaper_time.should eq 3600
  end

  it "can create a full namespace from environment and namespace" do
    config = load_config
    config.full_namespace.should eq "test:test"
  end
end

def load_config
  file = File.read("./spec/config_test.yml")
  Rockethook::Config.from_yaml(file)
end

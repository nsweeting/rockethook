require "yaml"

module Rockethook
  class Config
    BASE = "nothing: here"

    YAML.mapping(
      redis_pool:       { type: Int32, default: 25 },
      redis_timeout:    { type: Float64, default: 5.0 },
      concurrency:      { type: Int32, default: 10 },
      logging:          { type: Bool, default: true },
      max_attempts:     { type: Int32, default: 5 },
      retry_schedule:   { type: Array(Int32), default: [60, 300, 1000, 2000]},
      pinger:           { type: Bool, default: true },
      namespace:        { type: String, default: "webhooks" },
      environment:      { type: String, default: "development" },
      reaper_time:      { type: Int32, default: 3600 }
    )

    def full_namespace
      "#{environment}:#{namespace}"
    end
  end
end

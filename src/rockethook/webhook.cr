require "json"
require "secure_random"
require "openssl/hmac"
require "http/headers"

module Rockethook
  struct Webhook
    JSON.mapping(
      uuid:       { type: String, default: SecureRandom.uuid },
      context:    { type: String, default: "" },
      uri:        { type: String, default: "" },
      token:      { type: String, default: "" },
      event:      { type: String, default: "" },
      payload:    { type: JSON::Any, default: JSON::Any.new("") },
      created:    { type: Int32 | Int64, default: Time.now.epoch },
      attempts:   { type: Int32, default: 0 }
    )

    def bump_attempts
      self.attempts += 1
    end

    def headers
      HTTP::Headers{
        "X-Webhook-Context" => context,
        "X-Webhook-Signature" => generate_hmac,
        "X-Webhook-Event" => event
      }
    end

    def generate_hmac
      Base64.encode(OpenSSL::HMAC.digest(:sha256, token, payload.to_json)).strip
    end
  end
end

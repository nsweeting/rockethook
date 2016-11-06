module Rockethook
  USER_AGENT = "Activehook #{VERSION}"

  class Webhook
    JSON.mapping(
      uuid:       { type: String, default: SecureRandom.uuid },
      uri:        { type: String, default: "" },
      token:      { type: String, default: "" },
      created:    { type: Int32 | Int64, default: Time.now.epoch },
      attempts:   { type: Int32, default: 0 },
      topic:      { type: String, default: "" },
      payload:    { type: String, default: "" }
    )

    def fail
      bump_attempts
      return if max_attempts?
      queue_for_retry
    end

    def bump_attempts
      self.attempts = attempts + 1
    end

    def headers
      HTTP::Headers{ "User-agent" => Rockethook::USER_AGENT,
                     "X-Webhook-Token" => generate_hmac,
                     "X-Webhook-Topic" => topic }
    end

    private def generate_hmac
      Base64.encode(OpenSSL::HMAC.digest(:sha256, token, payload.to_s)).strip
    end
  end
end

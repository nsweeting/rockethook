module Rockethook
  USER_AGENT = "Rockethook/#{VERSION}"

  class Webhook
    JSON.mapping(
      uuid:       { type: String, default: SecureRandom.uuid },
      context:    { type: String, default: "" },
      uri:        { type: String, default: "" },
      token:      { type: String, default: "" },
      event:      { type: String, default: "" },
      payload:    { type: String, default: "" },
      created:    { type: Int32 | Int64, default: Time.now.epoch },
      attempts:   { type: Int32, default: 0 }
    )

    def fail
      bump_attempts
      return if max_attempts?
      queue_for_retry
    end

    def bump_attempts
      self.attempts += 1
    end

    def headers
      HTTP::Headers{ "User-agent" => Rockethook::USER_AGENT,
                     "X-Webhook-Context" => context,
                     "X-Webhook-Signature" => generate_hmac,
                     "X-Webhook-Event" => event }
    end

    private def generate_hmac
      Base64.encode(OpenSSL::HMAC.digest(:sha256, token, payload.to_s)).strip
    end
  end
end

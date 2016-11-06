module Rockethook
  class Deliverer
    def initialize(@manager : Manager)
      @done = false
    end

    def start
      spawn do
        until stop
          hook = fetch_hook
          post(hook) if hook
        end
      end
    end

    def fetch_hook
      @manager.fetcher.pop_one
    end

    def post(hook)
      response = HTTP::Client.post(hook.uri, hook.headers, body: hook.payload)
      raise "Response Error" unless response.success?
    rescue
      hook.bump_attempts
      @manager.delayer.add_one(hook)
    end

    private def stop
      @manager.stop?
    end
  end
end

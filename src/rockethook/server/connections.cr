require "http/client"

module Rockethook
  module Server
    class Connections
      property pools : Hash(String, Rockethook::Server::HTTPPool)

      def initialize(@cxt : Rockethook::Context)
        @pools = {} of String => Rockethook::Server::HTTPPool
      end

      def [](uri : URI)
        key = uri.host.to_s
        pools[key]? || new_pool(key, uri)
      end

      def delete_old!
        time = Time.now.epoch - @cxt.config.reaper_time
        pools.each do |pool|
          next if pool.last.created_at > time
          pools.delete(pool.first)
        end
      end

      private def new_pool(key, uri)
        pools[key] = Rockethook::Server::HTTPPool.new(uri)
      end
    end

    struct HTTPPool
      getter created_at : Int64
      property! config : URI
      property! size : Int32
      property! timeout : Float64
      property pool : ConnectionPool(HTTP::Client)

      def initialize(config : URI, @size = 5, @timeout = 5.0)
        @config = config
        @pool = build_pool
        @created_at = Time.now.epoch
      end

      def client
        pool.connection { |conn| yield conn }
      end

      private def build_pool
        ConnectionPool(HTTP::Client).new(capacity: size, timeout: timeout) do
          HTTP::Client.new(config)
        end
      end
    end
  end
end

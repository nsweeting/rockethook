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
        pools.has_key?(key) ? pools[key] : add_pool(key, uri)
      end

      def add_pool(key : String, uri : URI)
        pools[key] = Rockethook::Server::HTTPPool.new(uri)
      end

      def delete_old!(time = Time.now.epoch)
        pools.each do |pool|
          next unless pool.last.created_at < time
          pools.delete(pool.first)
        end
      end
    end

    class ConnectionCollector
      def initialize(@manager : Rockethook::Server::Manager)
      end

      def start
        spawn do
          until stop
            connections.delete_old!
            sleep 60
          end
        end
      end

      private def stop
        @manager.stop?
      end

      private def connections
        @manager.connections
      end
    end

    class HTTPPool
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

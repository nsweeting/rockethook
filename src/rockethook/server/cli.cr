require "option_parser"
require "../config"
require "../context"
require "../version"
require "./manager"

module Rockethook
  module Server
    class CLI
      getter context : Rockethook::Context
      getter manager : Rockethook::Server::Manager

      def initialize(argv = ARGV)
        @config = Rockethook::Config::BASE
        parse_options(argv)
        config = Rockethook::Config.from_yaml(@config)
        @context = Rockethook::Context.new(config)
        @manager = Rockethook::Server::Manager.new(context)
      end

      def start
        boot_message
        manager.start
        wait
        exit(0)
      end

      def parse_options(argv)
        OptionParser.parse(argv) do |parser|
          parser.banner = "Activehook v#{Rockethook::VERSION} in Crystal #{Crystal::VERSION}\n
                          Usage: activehook [arguments]"
          parser.on("-c FILE", "--config=file", "Path to config YAML") do |file|
            @config = File.read(file)
          end
          parser.on("-h", "--help", "Show this help") { puts parser }
        end
      end

      def boot_message
        context.logger.info("Booting Rockethook v#{Rockethook::VERSION}")
        context.logger.info("Starting with #{context.config.concurrency} deliverers")
      end

      def wait
        channel = Channel(Int32).new
        Signal::INT.trap do
          manager.stop!
          channel.send(0)
        end
        Signal::TERM.trap do
          manager.stop!
          channel.send(0)
        end
        Signal::USR1.trap do
          manager.stop!
        end
        channel.receive
      end
    end
  end
end

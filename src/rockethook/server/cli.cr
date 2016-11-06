module Rockethook
  module Server
    class CLI
      getter context : Rockethook::Context
      getter manager : Rockethook::Server::Manager
      getter logger : ::Logger

      def initialize(argv = ARGV)
        @config = Rockethook::Config::BASE
        parse_options(argv)
        @logger = Logger.build
        config = Rockethook::Config.from_yaml(@config)
        @context = Rockethook::Context.new(config)
        @manager = Rockethook::Server::Manager.new(context)
      end

      def start
        logger.info " in Crystal #{Crystal::VERSION}"
        logger.info "Starting processing with #{context.config.concurrency} workers"

        
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

      def banner
        %Q{
    ############################################
    ################''###  #####################
    #############'    ###  #####################
    ###########'      ###  #####################
    #########'        ###  #####################
    ########'         ###  #####################
    #######'          ###  ##'##################
    ######'           ###  ##   '###############
    #####'            ###  ##     '#############
    ####'             ###  ##       '###########
    ###'              ###  ##         '#########
    ###'              ###  ##           '#######
    #####################  #####################
    ###                                       ##
    ###.                                      ##
    #####.                                  .###
    ############################################
    ############################################
  }
      end

      def print_banner
          puts banner

      end
    end
  end
end

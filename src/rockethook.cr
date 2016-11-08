require "./rockethook/server/cli"

module Rockethook
  cli = Rockethook::Server::CLI.new
  cli.start
end

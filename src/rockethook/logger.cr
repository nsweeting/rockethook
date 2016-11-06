module Rockethook
  class Logger
    def self.build
      logger = ::Logger.new(STDOUT)
      logger.level = ::Logger::INFO
      logger
    end
  end
end

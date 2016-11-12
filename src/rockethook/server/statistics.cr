module Rockethook
  module Server
    class Statistics
      getter success : Int32
      getter failure : Int32
      getter start : Int32 | Int64

      def initialize(@cxt : Rockethook::Context)
        @success   = 0
        @failure   = 0
        @start     = Time.now.epoch
      end

      def update
        @cxt.logger.info("Success: #{success}, Failure: #{failure}")
      end

      def success!
        @success += 1
      end

      def failure!
        @failure += 1
      end
    end
  end
end

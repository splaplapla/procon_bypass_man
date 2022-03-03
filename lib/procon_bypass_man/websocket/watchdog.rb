module ProconBypassMan
  module Websocket
    class Watchdog
      def self.outdated?
        @@time < Time.now
      end

      def self.time
        @@time
      end

      def self.active!
        @@time = Time.now + 100
      end

      active!
    end
  end
end

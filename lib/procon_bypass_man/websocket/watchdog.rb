module ProconBypassMan
  module Websocket
    class Watchdog
      def self.outdated?
        @@time < (Time.now + 60)
      end

      def self.active!
        @@time = Time.now
      end

      active!
    end
  end
end

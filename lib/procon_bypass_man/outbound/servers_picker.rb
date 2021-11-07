module ProconBypassMan
  module Outbound
    class ServersPicker
      def initialize(servers: )
        if servers.nil? || servers.empty?
          return
        end

        @servers = servers
        if @servers.size >= 1
          @index = 0
        else
          @index = nil
        end
      end

      def pick
        if @index.nil?
          return @servers&.first
        end
        val = @servers[@index] || (reset && @servers[@index])
        inc_index
        return val
      end

      def reset
        @index = 0
      end

      def inc_index
        @index = @index + 1
      end
    end
  end
end

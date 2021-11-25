module ProconBypassMan
  module Background
    class ServerPool
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
        @servers[@index] or raise "bug!!!"
      end
      def server; pick; end

      def next!
        inc_index
        if @servers[@index].nil?
          reset
          return
        end
      end

      private

      def reset
        @index = 0
      end

      def inc_index
        @index = @index + 1
      end
    end
  end
end

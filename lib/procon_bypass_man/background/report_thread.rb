module ProconBypassMan
  module Background
    class Reporter
      def self.start!
        new.start!
      end

      def start!
        return if defined?(@@thread)
        @@queue = Queue.new
        @@thread = Thread.new do
          while(item = @@queue.pop)
            item[:reporter_class].report(body: item[:data])
            sleep(1)
            print "."
          end
        end
      end

      def self.queue
        raise "Do not start this thread yet" unless defined?(@@queue)
        @@queue
      end
    end
  end
end

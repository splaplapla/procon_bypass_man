module ProconBypassMan
  module Background
    class Reporter
      MAX_QUEUE_SIZE = 100

      def self.start!
        new.start!
      end

      def start!
        return if defined?(@@thread)
        @@queue = Queue.new
        @@thread = Thread.new do
          while(item = @@queue.pop)
            begin
              result = item[:reporter_class].report(body: item[:data])
              sleep(1)
            rescue => e
              ProconBypassMan.logger.error(e)
            end
          end
        end
      end

      def self.queue
        raise "Do not start this thread yet" unless defined?(@@queue)
        @@queue
      end

      def self.push(hash)
        if queue.size > MAX_QUEUE_SIZE
          ProconBypassMan.logger.error('Over queue size cap!!')
          return
        end

        queue.push(hash)
      end
    end
  end
end

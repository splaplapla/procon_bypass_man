module ProconBypassMan
  module Background
    class JobRunner
      MAX_QUEUE_SIZE = 100

      def self.start!
        new.start!
      end

      # for test
      def self.stop!
        return unless defined?(@@thread)
        @@thread.kill
      end

      def start!
        return if defined?(@@thread)
        @@thread = Thread.new do
          while(item = self.class.queue.pop)
            begin
              JobPerformer.new(klass: item[:reporter_class], args: item[:args]).perform
              sleep(1)
            rescue => e
              ProconBypassMan.logger.error(e)
            end
          end
        end
      end

      def self.queue
        @@queue ||= Queue.new
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

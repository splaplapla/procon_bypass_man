module ProconBypassMan
  module Background
    class Reporter
      MAX_QUEUE_SIZE = 100

      def self.start!
        new.start!
      end

      def start!
        return if defined?(@@thread)
        @@latest_request_result = { stats: true, timestamp: Time.now }
        @@queue = Queue.new
        @@thread = Thread.new do
          while(item = @@queue.pop)
            result = item[:reporter_class].report(body: item[:data])
            @@latest_request_result = { stats: result.stats, timestamp: Time.now }
            sleep(1)
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

        unless @@latest_request_result[:stats]
          @@latese_request_result[:timestamp] < (Time.now + 30)
          ProconBypassMan.logger.error('Skip report because need cooldown!!')
          return
        end

        queue.push(hash)
      end
    end
  end
end

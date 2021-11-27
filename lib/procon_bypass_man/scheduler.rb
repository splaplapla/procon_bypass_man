module ProconBypassMan
  class Scheduler
    class Schedule
      attr_accessor :klass, :interval, :next_enqueue_at

      def initialize(klass: , interval: )
        self.klass = klass
        self.interval = interval
        set_next_enqueue_at!
      end

      def enqueue
        @klass.perform_async
        set_next_enqueue_at!
      end

      def past_interval?
        next_enqueue_at < Time.now
      end

      private

      def set_next_enqueue_at!
        self.next_enqueue_at = Time.now + interval
      end
    end

    # @return [Hash]
    def self.schedules
      @@schedules
    end

    @@schedules = {}

    def self.start!
      register_schedules

      @@thread = Thread.start do
        loop do
          schedules.each do |_key, schedule|
            if schedule.past_interval?
              schedule.enqueue
            end
          end
          sleep 10
        end
      end
    end

    def self.register_schedules
      register(schedule: Schedule.new(klass: ProconBypassMan::FetchAndRunRemotePbmActionJob, interval: 60))
    end

    # @param [Schedule] schedule
    def self.register(schedule: )
      schedules[schedule.klass] = schedule
    end
  end
end

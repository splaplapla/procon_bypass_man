module ProconBypassMan
  class Scheduler
    class Schedule
      attr_accessor :klass, :args, :interval, :next_enqueue_at

      # @param [any] klass
      # @param [Array] args
      # @param [Integer] interval
      def initialize(klass: , args: , interval: )
        self.klass = klass
        self.args = args
        self.interval = interval
        set_next_enqueue_at!
      end

      # @return [void]
      def enqueue
        klass.perform_async(*unwrap_args(args))
        set_next_enqueue_at!
      end

      # @return [boolean]
      def past_interval?
        next_enqueue_at < Time.now
      end

      private

      # @return [void]
      def set_next_enqueue_at!
        self.next_enqueue_at = Time.now + interval
      end

      # @param [Array] args
      # @return [void]
      def unwrap_args(args)
        args.map do |arg|
          case arg
          when Proc
            arg.call
          else
            arg
          end
        end
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
      register(
        schedule: Schedule.new(
          klass: ProconBypassMan::FetchAndRunRemotePbmActionJob,
          args: [],
          interval: 3,
        )
      )
      register(
        schedule: Schedule.new(
          klass: ProconBypassMan::SyncDeviceStatsJob,
          args: [->{ ProconBypassMan::DeviceStatus.current }],
          interval: 60,
        )
      )
    end

    # @param [Schedule] schedule
    def self.register(schedule: )
      schedules[schedule.klass] = schedule
    end
  end
end

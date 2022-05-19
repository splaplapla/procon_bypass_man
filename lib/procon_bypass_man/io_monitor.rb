module ProconBypassMan
  class NullCounter
    def initialize(label: )
    end

    def record(_)
    end

    def shutdown
    end
  end

  class Counter
    attr_accessor :label, :table, :previous_table, :active

    def initialize(label: )
      self.label = label
      self.table = {}
      self.previous_table = {}
      self.active = true
    end

    # アクティブなバケットは1つだけ
    def record(event_name)
      key = Time.now.strftime("%S").to_i
      if table[key].nil?
        self.previous_table = table.values.first
        self.table = {}
        table[key] = {}
      end
      if table[key][event_name].nil?
        table[key][event_name] = 1
      else
        table[key][event_name] += 1
      end
      self
    end

    def formatted_previous_table
      t = previous_table.dup
      start_function = t[:start_function] || 0
      end_function = t[:end_function] || 0
      eagain_wait_readable_on_read = t[:eagain_wait_readable_on_read] || 0
      eagain_wait_readable_on_write = t[:eagain_wait_readable_on_write] || 0
      "(#{(end_function / start_function.to_f * 100).floor(1)}%(#{end_function}/#{start_function}), loss: #{eagain_wait_readable_on_read}, #{eagain_wait_readable_on_write})"
    end

    def shutdown
      self.active = false
    end
  end

  module IOMonitor
    @@thread = nil

    def self.new(label: )
      return NullCounter.new(label: label) if not started?

      counter = Counter.new(label: label)
      @@list << counter
      counter
    end

    # @return [Array<Counter>]
    def self.targets
      @@list
    end

    def self.started?
      !!@@thread
    end

    # ここで集計する
    def self.start!
      @@thread = Thread.start do
        max_output_length = 0
        loop do
          list = @@list.select(&:active).dup
          unless list.all? { |x| x&.previous_table.is_a?(Hash) }
            sleep 0.5
            next
          end

          line = list.map { |counter|
            "#{counter.label}(#{counter.formatted_previous_table})"
          }.join(", ")
          max_output_length = line.length
          sleep 0.7

          if ENV["PBM_FOREGROUND"]
            print "\r"
            print " " * max_output_length
            print "\r"
            print line
          end
          ProconBypassMan.logger.debug { line }
          break if $will_terminate_token
        end
      end
    end

    def self.reset!
      @@list = []
    end

    reset!
  end
end

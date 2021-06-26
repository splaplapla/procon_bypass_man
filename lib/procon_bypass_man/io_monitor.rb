module ProconBypassMan
  class Counter
    attr_accessor :label, :table, :previous_table

    def initialize(label: )
      self.label = label
      self.table = {}
      self.previous_table = {}
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

    def formated_previous_table
      t = previous_table.dup
      start_function = t[:start_function] || 0
      end_function = t[:end_function] || 0
      eagain_wait_readable_on_read = t[:eagain_wait_readable_on_read] || 0
      eagain_wait_readable_on_write = t[:eagain_wait_readable_on_write] || 0
      "(#{(end_function / start_function.to_f * 100).floor(1)}%(#{end_function}/#{start_function}), loss: #{eagain_wait_readable_on_read}, #{eagain_wait_readable_on_write})"
    end
  end

  module IOMonitor
    def self.new(label: )
      counter = Counter.new(label: label)
      @@list << counter
      counter
    end

    # @return [Array<Counter>]
    def self.targets
      @@list
    end

    # ここで集計する
    def self.start!
      Thread.start do
        max_output_length = 0
        loop do
          list = @@list.dup
          unless list.all? { |x| x&.previous_table.is_a?(Hash) }
            sleep 0.5
            next
          end

          s_to_p = list.detect { |x| x.label == "switch -> procon" }
          previous_table = s_to_p&.previous_table.dup
          if previous_table && previous_table.dig(:eagain_wait_readable_on_read) && previous_table.dig(:eagain_wait_readable_on_read) > 300
            # ProconBypassMan.logger.debug { "接続の確立ができません" }
            # Process.kill("USR1", Process.ppid)
          end

          line = list.map { |counter|
            "#{counter.label}(#{counter.formated_previous_table})"
          }.join(", ")
          max_output_length = line.length
          sleep 0.7
          print "\r"
          print " " * max_output_length
          print "\r"
          print line
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

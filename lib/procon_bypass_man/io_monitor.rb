module ProconBypassMan
  class Counter
    attr_accessor :table, :previous_table

    def initialize
      self.table = {}
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
    end
  end

  module Aggregation
    def self.aggregate(table)
      start_function = table[:start_function] || 0
      end_function = table[:end_function] || 0
      eagain_wait_readable_on_read = table[:eagain_wait_readable_on_read] || 0
      eagain_wait_readable_on_write = table[:eagain_wait_readable_on_write] || 0
      "(#{(end_function * 100 / start_function.to_f).floor(1)}%(#{end_function}/#{start_function}), loss: #{eagain_wait_readable_on_read}, #{eagain_wait_readable_on_write})"
    end
  end

  module IOMonitor
    def self.new(label: )
      counter = Counter.new
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
        @@list.map do |counter|
          Aggregation.aggregate(counter.previous_table)
        end
        sleep 0.7

        print "\r"
        print "なんらか"
      end
    end

    def self.reset!
      @@list = []
    end

    reset!
  end
end

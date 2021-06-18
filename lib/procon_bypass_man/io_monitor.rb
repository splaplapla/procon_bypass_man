module ProconBypassMan
  class Counter
    attr_accessor :table
    def initialize
      self.table = {}
    end

    def record(event_name)
      key = Time.now.strftime("%H").to_i
      if @table[key].nil?
        @table[key] = {}
      end
      if @table[key][event_name].nil?
        @table[key][event_name] = 1
      else
        @table[key][event_name] += 1
      end
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
        @@list.each do |list|
          # 集計
        end
        sleep 1

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

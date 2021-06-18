module ProconBypassMan
  class Counter
    def record(event_name)
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

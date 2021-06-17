module ProconBypassMan
  class Counter
    def before_read!
    end

    def after_read!
    end

    def before_write!
    end

    def after_write!
    end

    def eagain_wait_readable!
    end
  end

  module IOStats
    @@list = []

    def self.new(label: )
      @@list << Counter.new
    end

    def self.start_monitoring!
      Thread.start do
        @@list.each do |list|
          # 集計
        end
        sleep 1

        print "\r"
        print "なんらか"
      end
    end
  end
end

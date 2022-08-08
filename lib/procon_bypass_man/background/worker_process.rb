module ProconBypassMan
  module Background
    class WorkerProcess
      def self.run
        new.run
      end

      def run
        # ここでQueueをモニターする
      end
    end
  end
end

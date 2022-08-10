module ProconBypassMan
  module Background
    class WorkerProcess
      include ProconBypassMan::SignalHandler

      def self.run
        new.run
      end

      def run
        self_read, self_write = IO.pipe
        %w(TERM INT USR2).each do |sig|
          begin
            trap sig do
              self_write.puts(sig)
            end
          end
        end

        pool_queue_on_thread

        begin
          while(readable_io = IO.select([self_read]))
            signal = readable_io.first[0].gets.strip
            handle_signal(signal)
          end
        rescue ProconBypassMan::InterruptForRestart
          raise 'InterruptForRestartは想定外'
        rescue Interrupt
          ProconBypassMan::PrintMessageCommand.execute(text: "workerプロセスを処理を終了します")
        end
      end

      private

      def pool_queue_on_thread
        @thread = Thread.new do
          while(item = ProconBypassMan::Background::JobQueue.pop)
            begin
              JobPerformer.new(klass: item[:reporter_class], args: item[:args]).perform
            rescue => e
              ProconBypassMan.logger.error(e)
              sleep(0.2) # busy loopしないように
            end
          end
        end
      end
    end
  end
end

module ProconBypassMan
  class Worker
    attr_accessor :pid

    def self.run
      new.run
    end

    def run
      @thread = Thread.new do
        while(item = ProconBypassMan::Background::JobQueue.pop)
          begin
            # プロセスを越えるので、文字列でenqueueしてくれる前提なので、evalしてクラスにする
            JobPerformer.new(klass: eval(item[:reporter_class]), args: item[:args]).perform
          rescue => e
            ProconBypassMan.logger.error(e)
            sleep(0.2) # busy loopしないように
          end
        end
      end
    end

    def shutdown
    end
  end
end

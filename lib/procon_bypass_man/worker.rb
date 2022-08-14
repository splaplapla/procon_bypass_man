module ProconBypassMan
  class Worker
    attr_accessor :pid

    def self.run
      new.run
    end

    # @param [Boolean]
    def run
      return false if @thread
      @thread = Thread.new do
        while(item = ProconBypassMan::Background::JobQueue.pop)
          begin
            # プロセスを越えるので、文字列でenqueueしてくれる前提. evalしてクラスにする
            JobPerformer.new(klass: eval(item[:reporter_class]), args: item[:args]).perform
          rescue => e
            ProconBypassMan.logger.error(e)
            sleep(0.2) # busy loopしないように
          end
        end
      end

      return true
    end

    # 重要な非同期ジョブは存在しないのでqueueが捌けるのを待たずにkill
    def shutdown
      @thread&.kill
    end
  end
end

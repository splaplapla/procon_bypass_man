module ProconBypassMan
  class Worker
    attr_accessor :pid

    def self.run
      new.run
    end

    # @param [Boolean]
    def run
      return self if @thread
      @thread = Thread.new do
        while(item = ProconBypassMan::Background::JobQueue.pop)
          begin
            # プロセスを越えるので、文字列でenqueueしてくれる前提. evalしてクラスにする
            job_class = eval(item[:job_class])
            ProconBypassMan::Background::JobPerformer.new(klass: job_class, args: item[:args]).perform
          rescue => e
            ProconBypassMan.logger.error(e)
            if job_class.respond_to?(:re_enqueue_if_failed) && job_class.re_enqueue_if_failed
              job_class.perform_async(item[:args])
            end

            sleep(0.2) # busy loopしないように
          end
        end
      end

      return self
    end

    # 重要な非同期ジョブは存在しないのでqueueが捌けるのを待たずにkill
    def shutdown
      @thread&.kill
    end
  end
end

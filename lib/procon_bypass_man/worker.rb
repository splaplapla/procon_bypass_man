module ProconBypassMan
  class Worker
    attr_accessor :pid

    def self.run
      new.run
    end

    # @return [Worker]
    def run
      return self if @thread
      @thread = Thread.new do
        while(item = ProconBypassMan::Background::JobQueue.pop)
          job_class = eval(item[:job_class])
          work(job_class: job_class, args: item[:args])
          sleep(0.2) # busy loopしないように
        end
      end

      return self
    end

    def work(job_class: , args: )
      begin
        # プロセスを越えるので、文字列でenqueueしてくれる前提. evalしてクラスにする
        job_class.perform(*args)
      rescue => e
        ProconBypassMan.logger.error(e)
        if job_class.respond_to?(:re_enqueue_if_failed) && job_class.re_enqueue_if_failed
          job_class.perform_async(args)
        end
      end
    end

    # 重要な非同期ジョブは存在しないのでqueueが捌けるのを待たずにkill
    def shutdown
      @thread&.kill
    end
  end
end

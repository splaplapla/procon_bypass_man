module ProconBypassMan
  class Forever
    # 動作確認方法
    # - 10秒ごとにrefreshするのでタイムアウトは起きない
    #   - ProconBypassMan::Forever.run { loop { puts(:hi); sleep(10); } }
    # - タイムアウトが起きること
    #   - ProconBypassMan::Forever.run { puts(:hi); sleep(101);  }
    def self.run(&block)
      loop do
        new.run(&block)
      end
    end

    # @return [void]
    def run(&block)
      raise(ArgumentError, "need a block") unless block_given?

      thread = work_one(callable: block)
      wait_and_kill_if_outdated(thread)
    end

    # @param [Proc] callable
    # @return [Thread]
    def work_one(callable: )
      Thread.start do
        callable.call
      rescue => e
        ProconBypassMan.logger.error("[Forever] #{e.full_message}")
      end
    end

    # @param [Thread]
    # @return [void]
    def wait_and_kill_if_outdated(thread)
      watchdog = ProconBypassMan::Watchdog.new
      loop do
        if watchdog.outdated?
          watchdog.active!
          ProconBypassMan.logger.error("watchdog timeout!!")
          thread.kill
          return
        end

        sleep(10)
      end
    end
  end
end

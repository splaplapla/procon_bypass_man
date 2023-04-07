module ProconBypassMan
  class Forever
    # 動作確認方法
    # - 10秒ごとにrefreshするのでタイムアウトは起きない
    #   - ProconBypassMan::Forever.run { |watchdog| loop { puts(:hi); sleep(10); watchdog.active! } }
    # - タイムアウトが起きること
    #   - ProconBypassMan::Forever.run { |watchdog| loop { puts(:hi); sleep(10); } }
    def self.run(&block)
      loop do
        new.run(&block)
      end
    end

    # @return [void]
    def run(&block)
      raise(ArgumentError, "need a block") unless block_given?

      thread, watchdog = work_one(callable: block)
      wait_and_kill_if_outdated(thread, watchdog)
    end

    # @param [Proc] callable
    # @return [Array<Thread, ProconBypassMan::Watchdog>]
    def work_one(callable: )
      watchdog = ProconBypassMan::Watchdog.new
      thread = Thread.start do
        callable.call(watchdog)
      rescue => e
        ProconBypassMan.logger.error("[Forever] #{e.full_message}")
      end

      return [thread, watchdog]
    end

    # @param [ProconBypassMan::Watchdog] watchdog
    # @param [Thread] thread
    # @return [void]
    def wait_and_kill_if_outdated(thread, watchdog)
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

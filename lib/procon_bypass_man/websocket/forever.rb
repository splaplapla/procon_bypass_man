module ProconBypassMan
  module Websocket
    class Forever
      # 動作確認方法
      # - 10秒ごとにrefreshするのでタイムアウトは起きない
      #   - ProconBypassMan::Websocket::Forever.run { loop { puts(:hi); sleep(10); ProconBypassMan::Websocket::Watchdog.active!  } }
      # - タイムアウトが起きること
      #   - ProconBypassMan::Websocket::Forever.run { puts(:hi); sleep(3000);  }
      # - ブロックを1回評価するとThreadが死ぬので100秒後にタイムアウトが起きること
      #   - ProconBypassMan::Websocket::Forever.run { puts(:hi); sleep(10); ProconBypassMan::Websocket::Watchdog.active!  }
      def self.run(&block)
        loop do
          new.run(&block)
        end
      end

      def run(&block)
        raise("need a block") unless block_given?

        ws_thread = work_one(callable: block)
        wait_and_kill_if_outdated(ws_thread)
      end

      # @return [Thread]
      def work_one(callable: )
        Thread.start do
          callable.call
        rescue => e
          ProconBypassMan.logger.error("websocket client with forever: #{e.full_message}")
        end
      end

      def wait_and_kill_if_outdated(thread)
        loop do
          if Watchdog.outdated?
            Watchdog.active!
            ProconBypassMan.logger.error("watchdog timeout!!")
            thread.kill
            return
          end

          sleep(10)
        end
      end
    end
  end
end

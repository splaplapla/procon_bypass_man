module ProconBypassMan
  module Background
    module JobPerformable
      def perform(*)
        raise NotImplementedError, nil
      end

      def perform_async(*args)
        ProconBypassMan::Background::JobQueue.push(
          args: args,
          job_class: self.name, # drb上のQueueに格納するので念の為文字列入れて、取り出すときにevalでクラス化する
        )
      end
    end
  end
end

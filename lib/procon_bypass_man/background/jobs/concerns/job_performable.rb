module ProconBypassMan
  module Background
    module JobPerformable
      def perform(*)
        raise NotImplementedError, nil
      end

      def perform_async(*args)
        ProconBypassMan::Background::JobQueue.push(
          args: args,
          reporter_class: self,
        )
      end
    end
  end
end

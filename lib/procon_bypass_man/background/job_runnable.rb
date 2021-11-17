module ProconBypassMan
  module Background
    module JobRunnable
      def perform_async(*args)
        ProconBypassMan::Background::JobRunner.push(
          args: args,
          reporter_class: self,
        )
      end
    end
  end
end

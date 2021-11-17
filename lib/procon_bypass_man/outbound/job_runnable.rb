module ProconBypassMan
  module Outbound
    module JobRunnable
      def perform_async(*args)
        ProconBypassMan::Outbound::JobRunner.push(
          args: args,
          reporter_class: self,
        )
      end
    end
  end
end

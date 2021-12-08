module ProconBypassMan
  module RemotePbmAction
    class StopPbmAction < BaseAction

      def action_content(_args)
        ProconBypassMan.logger.info "execute StopPbmAction!"
        Process.kill("TERM", ProconBypassMan.pid)
      end

      private

      def before_action_callback
        be_processed
      end

      def after_action_callback
        # no-op
      end
    end
  end
end

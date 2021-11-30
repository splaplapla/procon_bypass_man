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
    end
  end
end

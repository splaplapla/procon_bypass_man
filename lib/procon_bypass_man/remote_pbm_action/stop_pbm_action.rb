module ProconBypassMan
  module RemotePbmAction
    class StopPbmAction < BaseAction

      def action_content
        ProconBypassMan.logger.info "execute StopPbmAction!"
      end

      private

      def before_action_callback
        be_processed
      end
    end
  end
end

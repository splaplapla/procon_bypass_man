module ProconBypassMan
  module RemotePbmAction
    class RebootPbmAction < BaseAction

      def action_content
        ProconBypassMan.logger.info "execute RebootPbmAction!"
      end

      private

      def before_action_callback
        be_processed
      end
    end
  end
end

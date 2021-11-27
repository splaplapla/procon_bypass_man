module ProconBypassMan
  module RemotePbmAction
    class RebootOsAction < BaseAction

      def action_content
        ProconBypassMan.logger.info "execute RebootOsAction!"
      end

      private

      def before_action_callback
        be_processed
      end
    end
  end
end

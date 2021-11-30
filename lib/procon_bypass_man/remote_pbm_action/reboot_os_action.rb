module ProconBypassMan
  module RemotePbmAction
    class RebootOsAction < BaseAction

      def action_content(_args)
        ProconBypassMan.logger.info "execute RebootOsAction!"
        `reboot`
      end

      private

      def before_action_callback
        be_processed
      end
    end
  end
end

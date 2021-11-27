module ProconBypassMan
  module RemotePbmAction
    class ChangePbmVersionAction < BaseAction

      def action_content
        # TODO
      end

      private

      def before_action_callback
        be_in_progress
      end

      def after_action_callback
        be_processed
      end
    end
  end
end

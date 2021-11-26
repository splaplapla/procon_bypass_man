module ProconBypassMan
  module RemotePbmAction
    class ChangePbmVersionAction < BaseAction
      def action_content
        # TODO
      end

      private

      def before_action
        be_in_progress
      end

      def after_action
        be_processed
      end
    end
  end
end

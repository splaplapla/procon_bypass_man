module ProconBypassMan
  module RemoteAction
    module RemotePbmJob
      class ReportProconStatusAction < BaseAction

        def action_content(_args)
          ProconBypassMan.logger.info "execute ReportProconStatusAction!"
          ProconBypassMan::SendInfoLogCommand.execute(
            message: ProconBypassMan::ProconDisplay::Status.instance.current.to_s
          )
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
end

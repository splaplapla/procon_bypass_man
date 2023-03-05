module ProconBypassMan
  module RemoteAction
    module RemotePbmJob
      class RunRemotePbmJobDispatchCommand
        # @param [String] action
        # @param [String] uuid
        # @return [void]
        def self.execute(action: , uuid: , job_args: )
          case action
          when ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_CHANGE_PBM_VERSION
            ProconBypassMan::RemoteAction::RemotePbmJob::ChangePbmVersionAction.new(pbm_job_uuid: uuid).run!(job_args: job_args)
          when ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_STOP_PBM
            ProconBypassMan::RemoteAction::RemotePbmJob::StopPbmJob.new(pbm_job_uuid: uuid).run!(job_args: {})
          when ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_REBOOT_OS
            ProconBypassMan::RemoteAction::RemotePbmJob::RebootOsAction.new(pbm_job_uuid: uuid).run!(job_args: {})
          when ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_RESTORE_SETTING
            ProconBypassMan::RemoteAction::RemotePbmJob::RestorePbmSettingAction.new(pbm_job_uuid: uuid).run!(job_args: job_args)
          when ProconBypassMan::RemoteAction::RemotePbmJob::ACTION_REPORT_PORCON_STATUS
            ProconBypassMan::RemoteAction::RemotePbmJob::ReportProconStatusAction.new(pbm_job_uuid: uuid).run!(job_args: {})
          else
            raise "#{action}は対応していないアクションです"
          end
        rescue ProconBypassMan::RemoteAction::RemotePbmJob::ActionUnexpectedError => e
          ProconBypassMan::SendErrorCommand.execute(error: e)
        end
      end
    end
  end
end

class ProconBypassMan::RunRemotePbmActionDispatchCommand
  # @param [String] action
  # @param [String] uuid
  # @return [void]
  def self.execute(action: , uuid: , job_args: )
    case action
    when ProconBypassMan::RemotePbmAction::ACTION_CHANGE_PBM_VERSION
      ProconBypassMan::RemotePbmAction::ChangePbmVersionAction.new(pbm_job_uuid: uuid).run!(job_args: job_args)
    when ProconBypassMan::RemotePbmAction::ACTION_STOP_PBM
      ProconBypassMan::RemotePbmAction::StopPbmAction.new(pbm_job_uuid: uuid).run!(job_args: {})
    when ProconBypassMan::RemotePbmAction::ACTION_REBOOT_OS
      ProconBypassMan::RemotePbmAction::RebootOsAction.new(pbm_job_uuid: uuid).run!(job_args: {})
    when ProconBypassMan::RemotePbmAction::ACTION_RESTORE_SETTING
      ProconBypassMan::RemotePbmAction::RestorePbmSettingAction.new(pbm_job_uuid: uuid).run!(job_args: job_args)
    else
      ProconBypassMan::SendErrorCommand.execute(error: "#{action}は対応していないアクションです")
    end
  rescue ProconBypassMan::RemotePbmAction::ActionUnexpectedError => e
    ProconBypassMan::SendErrorCommand.execute(error: e)
  end
end

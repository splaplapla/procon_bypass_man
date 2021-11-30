class ProconBypassMan::RunRemotePbmActionDispatchCommand
  # @param [String] action
  # @param [String] uuid
  # @return [void]
  def self.execute(action: , uuid: )
    case action
    when ProconBypassMan::RemotePbmAction::ACTION_CHANGE_PBM_VERSION
      ProconBypassMan::RemotePbmAction::ChangePbmVersionAction.new(pbm_job_uuid: uuid).run!
    when ProconBypassMan::RemotePbmAction::ACTION_STOP_PBM
      ProconBypassMan::RemotePbmAction::StopPbmAction.new(pbm_job_uuid: uuid).run!
    when ProconBypassMan::RemotePbmAction::ACTION_REBOOT_OS
      ProconBypassMan::RemotePbmAction::RebootOsAction.new(pbm_job_uuid: uuid).run!
    else
      ProconBypassMan::SendErrorCommand.execute(error: "#{action}は対応していないアクションです")
    end
  rescue ProconBypassMan::RemotePbmAction::ActionUnexpectedError => e
    ProconBypassMan::SendErrorCommand.execute(error: e)
  end
end

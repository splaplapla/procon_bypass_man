class ProconBypassMan::RunRemotePbmActionCommand
  def self.execute(action: , status: , uuid: )
    case action
    when ProconBypassMan::RemotePbmAction::CHANGE_PBM_VERSION
      ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: uuid).execute(to_status: :in_progress)
      ProconBypassMan::RemotePbmAction::ChangePbmVersionAction.execute!
      ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: uuid).execute(to_status: :processed)
    when ProconBypassMan::RemotePbmAction::REBOOT_PBM
      ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: uuid).execute(to_status: :processed)
      ProconBypassMan::RemotePbmAction::RebootOsAction.execute!
    when ProconBypassMan::RemotePbmAction::REBOOT_OS
      ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: uuid).execute(to_status: :processed)
      ProconBypassMan::RemotePbmAction::RebootOsAction.execute!
    else
      raise "unknown action"
    end
  rescue ProconBypassMan::RemotePbmAction::ActionUnexpectedError
    ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: uuid).execute(to_status: :failed)
  end
end

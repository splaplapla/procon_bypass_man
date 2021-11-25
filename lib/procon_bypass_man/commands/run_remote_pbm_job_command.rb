class ProconBypassMan::RunRemotePbmActionCommand
  def self.execute(action: , uuid: )
    ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: pbm_job_object.uuid).execute(to_status: :in_progress)
    ProconBypassMan::RunLocalShellCommand.execute!
    ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: pbm_job_object.uuid).execute(to_status: :processed)
  rescue ProconBypassMan::RunLocalShellCommand::LocalCommandError
    ProconBypassMan::UpdateRemotePbmActionCommand.new(pbm_job_uuid: pbm_job_object.uuid).execute(to_status: :failed)
  end
end

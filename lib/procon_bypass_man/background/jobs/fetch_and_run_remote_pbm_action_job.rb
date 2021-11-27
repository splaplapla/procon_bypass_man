class ProconBypassMan::FetchAndRunRemotePbmActionJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  def self.perform
    pbm_jobs = ProconBypassMan::HttpClient.new(path: path, server_pool: server_pool).get
    if pbm_jobs.size.zero?
      return
    else
      pbm_job_hash = pbm_jobs.first
      begin
        pbm_job_object = ProconBypassMan::RemotePbmActionObject.new(action: pbm_job_hash["action"],
                                                                    status: pbm_job_hash["status"],
                                                                    uuid: pbm_job_hash["uuid"],
                                                                    created_at: pbm_job_hash["created_at"])
        pbm_job_object.validate!
        ProconBypassMan::RunRemotePbmActionDispatchCommand.execute(action: pbm_job_object.action, uuid: pbm_job_object.uuid)
      rescue ProconBypassMan::RemotePbmActionObject::ValidationError => e
        ProconBypassMan::SendErrorCommand.execute(error: e)
      end
    end
  end

  def self.path
    device_id = ENV["DEBUG_DEVICE_ID"] || ProconBypassMan.device_id
    "/api/devices/#{device_id}/pbm_jobs"
  end
end

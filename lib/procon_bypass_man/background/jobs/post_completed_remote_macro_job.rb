class ProconBypassMan::PostCompletedRemoteMacroJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [Symbol] status
  def self.perform(job_id)
    ProconBypassMan::RemoteMacroHttpClient.new(
      path: path,
      server_pool: server_pool,
    ).post(job_id: job_id)
  end

  def self.path
    device_id = ProconBypassMan.device_id
    "/api/devices/#{ProconBypassMan.device_id}/completed_pbm_remote_macro_jobs"
  end
end


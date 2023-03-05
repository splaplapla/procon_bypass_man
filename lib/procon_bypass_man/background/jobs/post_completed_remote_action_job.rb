class ProconBypassMan::PostCompletedRemoteActionJob < ProconBypassMan::BaseJob
  extend ProconBypassMan::HasExternalApiSetting

  # @param [Symbol] status
  def self.perform(job_id)
    ProconBypassMan::RemoteMacroHttpClient.new(
      path: path,
      server: api_server,
    ).post(job_id: job_id)
  end

  def self.path
    device_id = ProconBypassMan.device_id
    "/api/devices/#{ProconBypassMan.device_id}/completed_pbm_remote_macro_jobs"
  end

  def self.re_enqueue_if_failed
    true
  end
end

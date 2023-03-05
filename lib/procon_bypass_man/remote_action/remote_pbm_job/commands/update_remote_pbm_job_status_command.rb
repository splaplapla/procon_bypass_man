module ProconBypassMan
  class UpdateRemotePbmJobStatusCommand
    # @param [String] pbm_job_uuid
    def initialize(pbm_job_uuid: )
      @pbm_job_uuid = pbm_job_uuid
    end

    # @param [String] to_status
    # @return [void]
    def execute(to_status: )
      ProconBypassMan::UpdateRemotePbmJobStatusHttpClient.new(
        path: path,
        server: ProconBypassMan.config.api_server,
      ).put(to_status: to_status)
    end

    private

    # @return [String]
    def path
      "/api/devices/#{ProconBypassMan.device_id}/pbm_jobs/#{@pbm_job_uuid}"
    end
  end
end

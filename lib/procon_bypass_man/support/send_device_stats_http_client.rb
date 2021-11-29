module ProconBypassMan
  class SendDeviceStatsHttpClient < HttpClient
    def post(status: , pbm_sessions_id: )
      super(request_body: {
        body: { status: status, pbm_sessions_id: pbm_sessions_id },
      })
    end
  end
end

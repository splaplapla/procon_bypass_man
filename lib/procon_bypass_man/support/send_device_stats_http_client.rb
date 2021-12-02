module ProconBypassMan
  class SendDeviceStatsHttpClient < HttpClient
    def post(status: , pbm_session_id: )
      super(request_body: {
        body: { status: status, pbm_session_id: pbm_session_id },
      })
    end
  end
end

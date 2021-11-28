module ProconBypassMan
  class SendDeviceStatsHttpClient < HttpClient
    def post(status: )
      super(request_body: {
        body: { status: status },
      })
    end
  end
end

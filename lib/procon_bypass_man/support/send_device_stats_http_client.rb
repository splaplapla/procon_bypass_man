module ProconBypassMan
  class SendDeviceStatsHttpClient < HttpClient
    def post(stats: )
      super(request_body: {
        body: { status: status },
      })
    end
  end
end

module ProconBypassMan
  class UpdateRemotePbmActionStatusHttpClient < HttpClient
    def put(to_status: )
      super(request_body: {
        body: { status: to_status },
      })
    end
  end
end

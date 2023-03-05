module ProconBypassMan
  class UpdateRemotePbmJobStatusHttpClient < HttpClient
    def put(to_status: )
      super(request_body: {
        body: { status: to_status },
      })
    end
  end
end

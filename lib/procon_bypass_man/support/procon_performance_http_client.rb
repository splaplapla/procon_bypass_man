module ProconBypassMan
  class ProconPerformanceHttpClient < HttpClient
    def post(body: )
      super(request_body: { body: body })
    end
  end
end

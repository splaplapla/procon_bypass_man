module ProconBypassMan::ProconDisplay
  class HttpResponse
    def initialize(body, status: )
      @body = body
      @status = status
    end

    def to_s
    end
  end
end

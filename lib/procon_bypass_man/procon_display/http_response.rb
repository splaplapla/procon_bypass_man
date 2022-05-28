module ProconBypassMan::ProconDisplay
  class HttpResponse
    def initialize(body, status: , format: "text/json")
      @body = body&.to_json
      @status = status
      @format = format
    end

    def to_s
      <<~EOH
        HTTP/1.1 #{@status}
        Content-Length: #{@body&.bytes&.size || 0}
        Content-Type: #{@format}
        Access-Control-Allow-Origin: *
        Access-Control-Allow-Methods: GET
        Access-Control-Allow-Private-Network：true

        #{@body}
      EOH
    end
  end
end

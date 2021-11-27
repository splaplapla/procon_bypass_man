module ProconBypassMan
  class ReportHttpClient < HttpClient
    def post(body: , event_type: )
      if body.is_a?(String)
        b = { text: body }
      else
        b = body
      end

      super(request_body: {
        session_id: ProconBypassMan.session_id,
        device_id: ProconBypassMan.device_id,
        hostname: `hostname`.chomp,
        event_type: event_type,
        body: b,
      })
    end
  end
end

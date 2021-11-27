module ProconBypassMan
  class ReportHttpClient < HttpClient
    def post(body: , event_type: )
      super(request_body: {
        session_id: ProconBypassMan.session_id,
        device_id: ProconBypassMan.device_id,
        hostname: `hostname`.chomp,
        event_type: event_type,
        body: body.to_json,
      })
    end
  end
end

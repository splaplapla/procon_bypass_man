require "procon_bypass_man/outbound/servers_picker"
require "procon_bypass_man/outbound/has_server_picker"

module ProconBypassMan
  module Outbound
    class Client
      class Http
        def self.request!(uri: , hostname: , body: , session_id: nil)
          @uri = uri
          @http = Net::HTTP.new(uri.host, uri.port)
          @http.use_ssl = uri.scheme === "https"
          @params = { hostname: hostname }.merge(body)
          @http.post(
            @uri.path,
            @params.to_json,
            { "Content-Type" => "application/json" },
          )
        end
      end

      def initialize(path: , server_picker: , retry_on_connection_error: false)
        @path = path
        @server_picker = server_picker
        @hostname = `hostname`.chomp
        @retry_on_connection_error = retry_on_connection_error
      end

      def post(body: , event_type: )
        if @server_picker.server.nil?
          ProconBypassMan.logger.info('送信先が未設定なのでスキップしました')
          return
        end
        if body.is_a?(Hash)
          body[:event_type] = event_type
          body = { body: body }
        else
          body = { body: { value: body, event_type: event_type } }
        end

        response = Http.request!(
          uri: URI.parse("#{@server_picker.server}#{@path}"), hostname: @hostname, session_id: nil, body: body
        )
        case response.code
        when /^200/
          return
        else
          @server_picker.next!
          ProconBypassMan.logger.error("200以外(#{response.code})が帰ってきました. #{response.body}")
        end
      rescue SocketError => e
        ProconBypassMan.logger.error("error in outbound module: #{e}")
        if @retry_on_connection_error
          sleep(10)
          retry
        end
      rescue => e
        puts e
        ProconBypassMan.logger.error("error in outbound module: #{e}")
      end
    end
  end
end

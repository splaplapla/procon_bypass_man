require "procon_bypass_man/outbound/servers_picker"
require "procon_bypass_man/outbound/has_server_picker"

module ProconBypassMan
  module Outbound
    class Client
      class Http
        class Response < Struct.new(:code, :body); end

        def initialize(uri: , hostname: , body: )
          unless body.is_a?(Hash)
            body = { value: body }
          end

          @uri = uri
          @http = Net::HTTP.new(uri.host, uri.port)
          @http.use_ssl = uri.scheme === "https"
          @params = { hostname: hostname }.merge(body)
        end

        def request!
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

      def post(body: )
        if @server_picker.server.nil?
          ProconBypassMan.logger.info('送信先が未設定なのでスキップしました')
          return
        end

        response = Http.new(
          uri: URI.parse("#{@server_picker.server}#{@path}"), hostname: @hostname, body: body
        ).request!
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

require "procon_bypass_man/outbound/servers_picker"

module ProconBypassMan
  module Outbound
    class Base
      class Client
        def initialize(path: , servers: )
          @path = path
          @server_picker = ProconBypassMan::Outbound::ServersPicker.new(servers: servers)
          @hostname = `hostname`.chomp
        end

        def post(body: )
          if @server_picker.server.nil?
            ProconBypassMan.logger.info('送信先が未設定なのでスキップしました')
            return
          end

          unless body.is_a?(Hash)
            body = { value: body }
          end

          uri = URI.parse("#{@server_picker.server}#{@path}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme === "https"
          params = { hostname: @hostname }.merge(body)
          response = http.post(
            uri.path,
            params.to_json,
            { "Content-Type" => "application/json" },
          )
          case response.code
          when /^200/
          else
            @server_picker.next!
            ProconBypassMan.logger.error("200以外(#{response.code})が帰ってきました. #{response.body}")
          end
        rescue => e
          puts e
          ProconBypassMan.logger.error("erro: #{e}")
        end
      end
    end
  end
end

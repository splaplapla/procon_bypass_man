module ProconBypassMan
  module Outbound
    class Base
      class Client
        def initialize(path: , server: )
          @path = path
          if server.is_a?(Array)
            @server = server.first
          else
            @server = server
          end
          @hostname = `hostname`.chomp
        end

        def post(body: )
          # TODO ここでvalidationする
          if @server.nil?
            ProconBypassMan.logger.info('送信先が未設定なのでスキップしました')
            return
          end

          uri = URI.parse("#{@server}#{@path}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme === "https"
          response = http.post(
            uri.path,
            { report: body, hostname: @hostname }.to_json,
            { "Content-Type" => "application/json" },
          )
          case response.code
          when /^200/
          else
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

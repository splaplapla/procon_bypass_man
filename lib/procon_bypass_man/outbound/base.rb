module ProconBypassMan
  module Outbound
    class Base
      class Client
        def initialize(path: )
          @path = path
          @server = ProconBypassMan.api_server
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
            { report: body.to_json, hostname: @hostname }.to_json,
            { "Content-Type" => "application/json" },
          )
          unless response.code == /^20/
            ProconBypassMan.logger.error(response.body)
          end
        rescue => e
          puts e
          ProconBypassMan.logger.error(e)
        end
      end
    end
  end
end

module ProconBypassMan
  module Outbound
    class Base
      class Client
        class ServerList
          def initialize(servers: )
            if servers.nil? || servers.empty?
              return
            end

            @servers = servers
            if @servers.size >= 1
              @index = 0
            else
              @index = nil
            end
          end

          def get_server
            if @index.nil?
              return @servers&.first
            end
            @servers[@index] || reset
            @servers[@index]
          end

          def reset
            @index = 0
          end
        end

        class Result < Struct.new(:stats); end

        def initialize(path: , servers: )
          @path = path
          @server = ServerList.new(servers: servers).get_server
          @hostname = `hostname`.chomp
        end

        def post(body: )
          # TODO ここでvalidationする
          if @server.nil?
            ProconBypassMan.logger.info('送信先が未設定なのでスキップしました')
            return Result.new(false)
          end

          unless body.is_a?(Hash)
            body = { value: body }
          end

          uri = URI.parse("#{@server}#{@path}")
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
            return Result.new(true)
          else
            ProconBypassMan.logger.error("200以外(#{response.code})が帰ってきました. #{response.body}")
            return Result.new(false)
          end
        rescue => e
          puts e
          ProconBypassMan.logger.error("erro: #{e}")
          Result.new(false)
        end
      end
    end
  end
end

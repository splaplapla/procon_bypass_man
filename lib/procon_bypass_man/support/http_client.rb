module ProconBypassMan
  class HttpClient
    class HttpRequest
      class Get
        def self.request!(uri: , hostname: , request_body: {}, event_type: nil)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme === "https"
          http.get(uri.path, { "Content-Type" => "application/json" })
        end
      end

      class Post
        def self.request!(uri: , hostname: , request_body: {}, event_type: nil)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme === "https"
          http.post(uri.path, request_body.to_json, { "Content-Type" => "application/json" })
        end
      end
    end

    def initialize(path: , pool_server: , retry_on_connection_error: false)
      @pool_server = pool_server
      @uri = URI.parse("#{pool_server.server}#{path}")
      @hostname = `hostname`.chomp
      @retry_on_connection_error = retry_on_connection_error
    end

    def get
      handle_request do
        response = HttpRequest::Get.request!(
          uri: @uri,
          hostname: @hostname,
        )
        break process_response(response)
      end
    end

    def post(body: , event_type: )
      handle_request do
        request_body = {
          body: body.to_json,
          hostname: @hostname,
          session_id: ProconBypassMan.session_id,
          device_id: ProconBypassMan.device_id,
          event_type: event_type,
        }
        response = HttpRequest::Post.request!(
          uri: @uri,
          hostname: @hostname,
          request_body: request_body,
          event_type: event_type,
        )
        break process_response(response)
      end
    end

    private

    def process_response(response)
      case response.code
      when /^200/
        return JSON.parse(response.body)
      else
        @pool_server.next!
        ProconBypassMan.logger.error("200以外(#{response.code})が帰ってきました. #{response.body}")
      end
    end

    def handle_request
      raise "need block" unless block_given?
      if @pool_server.server.nil?
        ProconBypassMan.logger.info('送信先が未設定なのでスキップしました')
        return
      end
      return yield
    rescue SocketError => e
      ProconBypassMan.logger.error(e)
      if @retry_on_connection_error
        sleep(10)
        retry
      end
    rescue => e
      puts e
      ProconBypassMan.logger.error(e)
    end
  end
end

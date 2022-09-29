module ProconBypassMan
  class HttpClient
    class HttpRequest
      class Get
        def self.request!(uri: )
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme === "https"
          http.get(uri.path, { "Content-Type" => "application/json" })
        end
      end

      class Post
        def self.request!(uri: , request_body: {})
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme === "https"
          http.post(uri.path, request_body.to_json, { "Content-Type" => "application/json" })
        end
      end

      class Put
        def self.request!(uri: , request_body: {})
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme === "https"
          http.put(uri.path, request_body.to_json, { "Content-Type" => "application/json" })
        end
      end
    end

    def initialize(path: , server: , retry_on_connection_error: false)
      @server = server
      @uri = URI.parse("#{server}#{path}")
      @retry_on_connection_error = retry_on_connection_error
    end

    def get
      handle_request do
        ProconBypassMan.logger.info "[HTTP] GET #{@uri}"
        response = HttpRequest::Get.request!(
          uri: @uri,
        )
        break process_response(response)
      end
    end

    def post(request_body: )
      handle_request do
        body = {}.merge!(request_body)
        ProconBypassMan.logger.info "[HTTP] POST #{@uri}"
        response = HttpRequest::Post.request!(
          uri: @uri,
          request_body: body,
        )
        break process_response(response)
      end
    end

    def put(request_body: )
      handle_request do
        body = {
          hostname: `hostname`.chomp,
        }.merge!(request_body)
        ProconBypassMan.logger.info "[HTTP] PUT #{@uri}"
        response = HttpRequest::Put.request!(
          uri: @uri,
          request_body: body,
        )
        break process_response(response)
      end
    end

    private

    def process_response(response)
      case response.code
      when /^200/
        begin
          return JSON.parse(response.body)
        rescue JSON::ParserError
          return response.body
        end
      else
        ProconBypassMan.logger.error("#{@uri}から200以外(#{response.code})が帰ってきました. #{response.body}")
      end
    end

    def handle_request
      raise "need block" unless block_given?
      if @server.nil?
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
      raise if respond_to?(:raise_if_failed) && raise_if_failed
    rescue Timeout::Error
      ProconBypassMan.logger.error(e)
      sleep(10)
      raise if respond_to?(:raise_if_failed) && raise_if_failed
    rescue => e
      ProconBypassMan.logger.error(e)
      raise if respond_to?(:raise_if_failed) && raise_if_failed
    end
  end
end

if $0 == __FILE__
  ProconBypassMan::HttpClient.new(path: '/', server: nil, retry_on_connection_error: false).get(response_body: '')
end

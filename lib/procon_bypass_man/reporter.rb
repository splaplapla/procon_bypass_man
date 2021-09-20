require "net/http"

class ProconBypassMan::Reporter
  PATH = "/api/reports" # POST
  # TODO JSON schemaの定義

  class Client
    def initialize
      @server = ProconBypassMan.api_server
      @hostname = `hostname`.chomp
    end

    def post(body: )
      # TODO ここでvalidationする
      if @server.nil?
        ProconBypassMan.logger.info('送信先が未設定なのでスキップしました')
        return
      end

      uri = URI.parse("#{@server}#{PATH}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      response = http.post(
        uri.path,
        { body: body, hostname: @hostname }.to_json,
        { "Content-Type" => "application/json" },
      )
      unless response.code == /^20/
        ProconBypassMan.logger.error(response.body)
      end
    rescue => e
      ProconBypassMan.logger.error(e)
    end
  end

  def self.report(body: )
    Client.new.post_boot(body: body)
  rescue => e
    ProconBypassMan.logger.error(e)
  end
end

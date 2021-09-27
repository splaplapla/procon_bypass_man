require "net/http"
require "json"

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

  def self.report(body: )
    Client.new.post(body: body)
  rescue => e
    ProconBypassMan.logger.error(e)
  end
end

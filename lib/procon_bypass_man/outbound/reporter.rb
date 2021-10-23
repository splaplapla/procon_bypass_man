require "procon_bypass_man/outbound/base"

class ProconBypassMan::Reporter < ProconBypassMan::Outbound::Base
  PATH = "/api/reports"

  def self.report(body: )
    Client.new(path: PATH).post(body: body.to_json)
  rescue => e
    ProconBypassMan.logger.error(e)
  end
end

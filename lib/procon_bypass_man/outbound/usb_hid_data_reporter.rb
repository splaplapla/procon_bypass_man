require "procon_bypass_man/outbound/base"

class ProconBypassMan::UsbHidDataReporter < ProconBypassMan::Outbound::Base
  PATH = "/api/usb_hid_chunks"

  def self.report(body: )
    Client.new(
      path: PATH,
      server: ProconBypassMan.internal_api_servers,
    ).post(body: body.to_json)
  end
end


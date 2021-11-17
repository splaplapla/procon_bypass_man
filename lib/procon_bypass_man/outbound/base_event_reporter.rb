require "procon_bypass_man/outbound/http_client"

class ProconBypassMan::BaseEventReporter
  extend ProconBypassMan::Outbound::HasRoundRobinServer

  def self.perform_async(*args)
    ProconBypassMan::Outbound::Worker.push(
      args: args,
      reporter_class: self,
    )
  end

  def self.servers
    ProconBypassMan.config.api_servers
  end

  def self.path
    "/api/events"
  end
end

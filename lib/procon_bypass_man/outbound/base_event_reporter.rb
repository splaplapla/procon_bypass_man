require "procon_bypass_man/outbound/http_client"
require "procon_bypass_man/outbound/has_round_robin_server"

class ProconBypassMan::BaseEventReporter
  extend ProconBypassMan::Outbound::HasRoundRobinServer

  def self.perform_async(*args)
    ProconBypassMan::Outbound::JobRunner.push(
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

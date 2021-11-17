require "procon_bypass_man/outbound/http_client"
require "procon_bypass_man/outbound/job_runnable"
require "procon_bypass_man/outbound/has_round_robin_server"

class ProconBypassMan::BaseEventReporter
  extend ProconBypassMan::Outbound::HasRoundRobinServer
  extend ProconBypassMan::Outbound::JobRunnable

  def self.servers
    ProconBypassMan.config.api_servers
  end

  def self.path
    "/api/events"
  end
end

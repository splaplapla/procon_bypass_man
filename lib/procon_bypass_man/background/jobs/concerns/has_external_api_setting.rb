module ProconBypassMan::HasExternalApiSetting
  def path
    "/api/events"
  end

  def servers
    ProconBypassMan.config.api_servers
  end
end

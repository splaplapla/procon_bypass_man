module ProconBypassMan::HasExternalApiSetting
  def servers
    ProconBypassMan.config.api_servers
  end
end

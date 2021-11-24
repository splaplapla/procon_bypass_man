module ProconBypassMan::HasInternalApiSetting
  def servers
    ProconBypassMan.config.internal_api_servers
  end
end

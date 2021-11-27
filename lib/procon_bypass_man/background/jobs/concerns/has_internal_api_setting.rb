module ProconBypassMan::HasInternalApiSetting
  def server_pool
    ProconBypassMan.config.internal_server_pool
  end
end

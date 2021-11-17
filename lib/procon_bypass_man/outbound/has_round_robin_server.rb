module ProconBypassMan::Outbound::HasRoundRobinServer
  def reset!
    @server_picker = nil
  end

  def server_picker
    @server_picker ||= ProconBypassMan::Outbound::RoundRobinServer.new(
      servers: servers
    )
  end

  def servers
    raise NotImplementedError, nil
  end
end

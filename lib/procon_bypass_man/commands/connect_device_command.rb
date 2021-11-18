class ProconBypassMan::ConnectDeviceCommand
  # @return [void]
  def self.execute!
    gadget, procon = ProconBypassMan::DeviceConnector.connect
  rescue ProconBypassMan::Timer::Timeout
    ::ProconBypassMan.logger.error "デバイスとの通信でタイムアウトが起きて接続ができませんでした。"
    gadget&.close
    procon&.close
    raise ::ProconBypassMan::EternalConnectionError
  end
end

class ProconBypassMan::ConnectDeviceCommand
  class NotFoundProconError < StandardError; end

  # @return [void]
  def self.execute!
    gadget, procon = ProconBypassMan::DeviceConnector.connect
  rescue ProconBypassMan::DeviceConnector::NotFoundProconError => e
    ProconBypassMan.logger.error e
    gadget&.close
    procon&.close
    raise ProconBypassMan::ConnectDeviceCommand::NotFoundProconError
  rescue ProconBypassMan::SafeTimeout::Timeout
    ProconBypassMan.logger.error "デバイスとの通信でタイムアウトが起きて接続ができませんでした。"
    gadget&.close
    procon&.close
    raise ProconBypassMan::EternalConnectionError
  end
end

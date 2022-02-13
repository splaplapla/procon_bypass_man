class ProconBypassMan::ConnectDeviceCommand
  class NotFoundProconError < StandardError; end

  # @return [void]
  def self.execute!
    unless has_required_files?
      raise ProconBypassMan::NotFoundRequiredFilesError, "there is not /sys/kernel/config/usb_gadget/procon"
    end

    begin
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

  def self.has_required_files?
    Dir.exist?("/sys/kernel/config/usb_gadget/procon")
  end
end

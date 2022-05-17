class ProconBypassMan::DeviceConnection::Command
  # @return [void]
  def self.execute!
    begin
      gadget, procon = ProconBypassMan::DeviceConnection::Executer.execute!
    rescue ProconBypassMan::DeviceConnection::NotFoundProconError => e
      ProconBypassMan.logger.error e
      gadget&.close
      procon&.close
      raise ProconBypassMan::DeviceConnection::NotFoundProconError
    rescue ProconBypassMan::DeviceConnection::FirstTimeoutError
      ProconBypassMan::SendErrorCommand.execute(error: "接続に失敗したのでもう一度トライします")
      sleep(2)
      retry
    rescue ProconBypassMan::SafeTimeout::Timeout
      ProconBypassMan.logger.error "デバイスとの通信でタイムアウトが起きて接続ができませんでした。"
      gadget&.close
      procon&.close
      raise ProconBypassMan::EternalConnectionError
    end

    ProconBypassMan::DeviceConnection::PreBypass.new(gadget: gadget, procon: procon).execute!
    ProconBypassMan::DeviceConnection::ProconSettingOverrider.new(procon: procon).execute!
    return [gadget, procon]
  end
end

class ProconBypassMan::DeviceConnection::Command
  # @return [void]
  def self.execute!
    begin
      gadget, procon = ProconBypassMan::DeviceConnection::Executer.execute!
    rescue ProconBypassMan::DeviceConnection::TimeoutErrorInConditionalRoute
      ProconBypassMan::SendErrorCommand.execute(error: "接続に失敗したのでもう一度トライします")
      sleep(2) # もう少し短くできると思うが、再現しにくくいので適当
      retry
    rescue ProconBypassMan::DeviceConnection::NotFoundProconError => e
      raise
    rescue ProconBypassMan::SafeTimeout::Timeout
      raise ProconBypassMan::DeviceConnection::TimeoutError
    end

    ProconBypassMan::DeviceConnection::PreBypass.new(gadget: gadget, procon: procon).execute!
    ProconBypassMan::DeviceConnection::ProconSettingOverrider.new(procon: procon).execute!
    return [gadget, procon]
  end
end

class ProconBypassMan::DeviceConnection::ProconLess::Command
  # @return [void]
  def self.execute!
    begin
      gadget, procon = ProconBypassMan::DeviceConnection::ProconLess::Executer.execute!
    rescue ProconBypassMan::SafeTimeout::Timeout
      raise ProconBypassMan::DeviceConnection::TimeoutError
    end

    ProconBypassMan::DeviceConnection::PreBypass.new(gadget: gadget, procon: procon).execute!
    return [gadget, procon]
  end
end

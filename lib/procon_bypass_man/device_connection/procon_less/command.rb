class ProconBypassMan::DeviceConnection::ProconLess::Command
  # @return [void]
  def self.execute!(retry_count: 0)
    begin
      gadget, procon = ProconBypassMan::DeviceConnection::ProconLess::Executer.execute!
    rescue ProconBypassMan::DeviceConnection::TimeoutErrorInConditionalRoute
    rescue ProconBypassMan::SafeTimeout::Timeout
      raise ProconBypassMan::DeviceConnection::TimeoutError
    end

    ProconBypassMan::DeviceConnection::PreBypass.new(gadget: gadget, procon: procon).execute!
    return [gadget, procon]
  end
end

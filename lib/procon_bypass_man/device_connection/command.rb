class ProconBypassMan::DeviceConnection::Command
  MAX_RETRY_COUNT = 3

  # @return [void]
  def self.execute!(retry_count: 0)
    begin
      gadget, procon = ProconBypassMan::DeviceConnection::Executer.execute!
    rescue ProconBypassMan::DeviceConnection::TimeoutErrorInConditionalRoute, ProconBypassMan::SafeTimeout::Timeout
      if retry_count >= MAX_RETRY_COUNT
        ProconBypassMan::SendErrorCommand.execute(error: "リトライしましたが、接続できませんでした")
        raise ProconBypassMan::DeviceConnection::TimeoutError
      else
        ProconBypassMan::SendErrorCommand.execute(error: "接続に失敗したのでリトライします")
      end

      retry_count = retry_count + 1
      retry
    rescue ProconBypassMan::DeviceConnection::NotFoundProconError, ProconBypassMan::DeviceConnection::SetupIncompleteError => e
      raise
    end

    ProconBypassMan::DeviceConnection::PreBypass.new(gadget: gadget, procon: procon).execute!
    ProconBypassMan::DeviceConnection::ProconSettingOverrider.new(procon: procon).execute!
    return [gadget, procon]
  end
end

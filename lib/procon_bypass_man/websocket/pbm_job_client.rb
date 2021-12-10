class ProconBypassMan::Websocket::PbmJobClient
  CHANNEL = 'PbmJobChannel'

  # TODO reconnect
  def run
    return unless ProconBypassMan.config.enable_ws?

    EventMachine.run do
      client = ActionCableClient.new(
        ProconBypassMan.config.current_ws_server_url, {
          channel: CHANNEL, device_id: ProconBypassMan.device_id
        }
      )
      client.connected { puts 'successfully connected.' }

      client.received do |message|
        ProconBypassMan.logger.info message
        # TODO ProconBypassMan::FetchAndRunRemotePbmActionJob 相当のことをやる
      end
    end
  end
end

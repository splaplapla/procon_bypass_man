class ProconBypassMan::Websocket::HeartbeatClient
  CHANNEL = 'HeartbeatChannel'

  # TODO reconnect
  def run
    return unless ProconBypassMan.config.enable_ws?

    EventMachine.run do
      client = ActionCableClient.new(
        ProconBypassMan.config.current_ws_server_url, {
          channel: CHANNEL, device_id: ProconBypassMan.device_id
        }
      )
      EM.add_periodic_timer(3) do
        client.perform('post', {
          status: ProconBypassMan::DeviceStatus.current,
          session_id: ProconBypassMan.session_id,
          device_id: ProconBypassMan.device_id,
        })
      end

      client.connected {
        ProconBypassMan.logger.info('successfully connected in ProconBypassMan::Websocket::HeartbeatClient' )
      }
      client.disconnected {
        puts :disconnected
        client.reconnect!
        sleep 2
      }
      client.connected { puts :connected}
      client.subscribed { puts :subscribed}
      client.errored { |msg|  puts :errored}
      client.received { |msg|  puts :received }
      client.pinged { |msg| puts :disconnected }
    end
  end
end

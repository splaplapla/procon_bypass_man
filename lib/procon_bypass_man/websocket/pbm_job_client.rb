module ProconBypassMan
  module Websocket
    module PbmJobClient
      CHANNEL = 'PbmJobChannel'

      def self.start!
        Thread.start { run }
      end

      def self.run
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

          client.connected {
            ProconBypassMan.logger.info('successfully connected in ProconBypassMan::Websocket::PbmJobClient' )
          }
          client.disconnected {
            puts :disconnected
            client.reconnect!
            sleep 2
          }
          client.connected { puts :connected}
          client.subscribed { puts :subscribed}
          client.errored { |msg|  puts :errored}
          client.pinged { |msg| puts :disconnected }
        end
      end
    end
  end
end

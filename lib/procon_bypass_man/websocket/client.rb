module ProconBypassMan
  module Websocket
    module Client
      CHANNEL = 'PbmJobChannel'

      def self.start!
        return unless ProconBypassMan.config.enable_ws?

        Thread.start do
          Forever.run { run }
        end
      end

      def self.run
        EventMachine.run do
          client = ActionCableClient.new(
            ProconBypassMan.config.current_ws_server_url, {
              channel: CHANNEL, device_id: ProconBypassMan.device_id,
            }
          )

          client.connected {
            ProconBypassMan.logger.info('websocket client: successfully connected in ProconBypassMan::Websocket::Client')
          }
          client.subscribed { |msg|
            ProconBypassMan.logger.info('websocket client: subscribed')
            ProconBypassMan::SyncDeviceStatsJob.perform(ProconBypassMan::DeviceStatus.current)
          }

          client.received do |data|
            ProconBypassMan.logger.info('websocket client: received!!')
            ProconBypassMan.logger.info(data)

            dispatch(data: data, client: client)
          rescue => e
            ProconBypassMan::SendErrorCommand.execute(error: e)
          end

          client.disconnected {
            ProconBypassMan.logger.info('websocket client: disconnected!!')
            puts :disconnected
            client.reconnect!
            sleep 2
          }
          client.errored { |msg|
            ProconBypassMan.logger.error("websocket client: errored!!, #{msg}")
            puts :errored
            client.reconnect!
            sleep 2
          }
          client.pinged { |msg|
            Watchdog.active!

            ProconBypassMan.cache.fetch key: 'ws_pinged', expires_in: 10 do
              ProconBypassMan.logger.info('websocket client: pinged!!')
              ProconBypassMan.logger.info(msg)
            end
          }
        end
      end

      # @param [Hash] data
      def self.dispatch(data: , client: )
        pbm_job_hash = data.dig("message")
        case pbm_job_hash['action']
        when "ping"
          client.perform('pong', { device_id: ProconBypassMan.device_id, message: 'hello from pbm' })
        when ProconBypassMan::RemoteMacro::ACTION_KEY
          validate_and_run_remote_macro(data: data)
        when *ProconBypassMan::RemotePbmAction::ACTIONS
          validate_and_run_remote_pbm_action(data: data)
        else
          ProconBypassMan.logger.error "unknown action"
        end
      end

      # @raise [ProconBypassMan::RemotePbmActionObject::ValidationError]
      # @param [Hash] data
      # @return [Void]
      def self.validate_and_run_remote_pbm_action(data: )
        pbm_job_hash = data.dig("message")
        begin
          pbm_job_object = ProconBypassMan::RemotePbmActionObject.new(action: pbm_job_hash["action"],
                                                                      status: pbm_job_hash["status"],
                                                                      uuid: pbm_job_hash["uuid"],
                                                                      created_at: pbm_job_hash["created_at"],
                                                                      job_args: pbm_job_hash["args"])
          pbm_job_object.validate!
        rescue ProconBypassMan::RemotePbmActionObject::ValidationError => e
          ProconBypassMan::SendErrorCommand.execute(error: e)
          return
        end

        ProconBypassMan::RunRemotePbmActionDispatchCommand.execute(
          action: pbm_job_object.action,
          uuid: pbm_job_object.uuid,
          job_args: pbm_job_object.job_args
        )
      end

      def self.validate_and_run_remote_macro(data: )
        pbm_job_hash = data.dig("message")
        begin
          remote_macro_object = ProconBypassMan::RemoteMacroObject.new(name: pbm_job_hash["name"],
                                                                       uuid: pbm_job_hash["uuid"],
                                                                       steps: pbm_job_hash["steps"])
          remote_macro_object.validate!
        rescue ProconBypassMan::RemoteMacroObject::ValidationError => e
          ProconBypassMan::SendErrorCommand.execute(error: e)
          return
        end

        ProconBypassMan::RemoteMacroSender.execute(
          name: remote_macro_object.name,
          uuid: remote_macro_object.uuid,
          steps: remote_macro_object.steps,
        )
      end
    end
  end
end

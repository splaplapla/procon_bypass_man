module ProconBypassMan
  module Websocket
    module PbmJobClient
      CHANNEL = 'PbmJobChannel'

      def self.start!
        return unless ProconBypassMan.config.enable_ws?

        Thread.start do
          loop do
            run
          rescue
            retry
          end
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
            ProconBypassMan.logger.info('successfully connected in ProconBypassMan::Websocket::PbmJobClient')
          }
          client.subscribed { |msg|
            puts({ event: :subscribed, msg: msg })
            ProconBypassMan::SyncDeviceStatsJob.perform(ProconBypassMan::DeviceStatus.current)
          }

          client.received do |data|
            ProconBypassMan.logger.info(data)

            dispatch(data: data, client: client)
          rescue => e
            ProconBypassMan::SendErrorCommand.execute(error: e)
          end

          client.disconnected {
            puts :disconnected
            client.reconnect!
            sleep 2
          }
          client.errored { |msg|  puts :errored; puts msg }
          client.pinged { |msg|
            ProconBypassMan.cache.fetch key: 'ws_pinged', expires_in: 10 do
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
        when "remote_macro"
          validate_and_send_macro_queue(data: data)
        when ProconBypassMan::RemotePbmAction::ACTIONS
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

      def self.validate_and_send_macro_queue(data: )
        pbm_job_hash = data.dig("message")
        begin
          remote_macro_object = ProconBypassMan::RemoteMacroObject.new(action: pbm_job_hash["action"],
                                                                       args: pbm_job_hash["args"])
          remote_macro_object.validate!
        rescue ProconBypassMan::RemoteMacroObject::ValidationError => e
          ProconBypassMan::SendErrorCommand.execute(error: e)
          return
        end

        # TODO extract class
        ProconBypassMan::QueueOverProcess
      end
    end
  end
end

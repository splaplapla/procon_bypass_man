module ProconBypassMan
  module Websocket
    module Client
      CHANNEL = 'PbmJobChannel'

      def self.start!
        return unless ProconBypassMan.config.enable_ws?

        Thread.start do
          ProconBypassMan::Forever.run do |watchdog|
            run(watchdog: watchdog)
          end
        end
      end

      def self.run(watchdog: )
        EventMachine.run do
          client = ActionCableClient.new(
            ProconBypassMan.config.current_ws_server_url, {
              channel: CHANNEL, device_id: ProconBypassMan.device_id,
            }
          )

          client.connected {
            ProconBypassMan.logger.info('[WebsocketClient] successfully connected in ProconBypassMan::Websocket::Client')
          }
          client.subscribed { |msg|
            ProconBypassMan.logger.info("[WebsocketClient] subscribed(#{msg})")
            ProconBypassMan::SyncDeviceStatsJob.perform(ProconBypassMan::DeviceStatus.current)
          }

          client.received do |data|
            ProconBypassMan.logger.info('[WebsocketClient] received!!')
            ProconBypassMan.logger.info(data)

            dispatch(data: data, client: client)
          rescue => e
            ProconBypassMan::SendErrorCommand.execute(error: e)
          end

          client.disconnected {
            ProconBypassMan.logger.info('[WebsocketClient] disconnected!!')
            client.reconnect!
            sleep 2
          }
          client.errored { |msg|
            ProconBypassMan.logger.error("[WebsocketClient] errored!!, #{msg}")
            client.reconnect!
            sleep 2
          }
          client.pinged { |msg|
            watchdog.active!

            ProconBypassMan.cache.fetch key: 'ws_pinged', expires_in: 10 do
              ProconBypassMan.logger.debug('[WebsocketClient] pinged!!')
              ProconBypassMan.logger.debug(msg)
            end
          }
        end
      end

      # @param [Hash] data
      def self.dispatch(data: , client: )
        case data.dig("message")['action']
        when "ping"
          client.perform('pong', { device_id: ProconBypassMan.device_id, message: 'hello from pbm' })
        when ProconBypassMan::RemoteAction::ACTION_MACRO
          run_remote_macro(data: data)
        when *ProconBypassMan::RemoteAction::RemotePbmJob::ACTIONS_IN_MASTER_PROCESS
          run_remote_pbm_job(data: data, process_to_execute: :master)
        when *ProconBypassMan::RemoteAction::RemotePbmJob::ACTIONS_IN_BYPASS_PROCESS
          run_remote_pbm_job(data: data, process_to_execute: :bypass)
        else
          ProconBypassMan::SendErrorCommand.execute(error: 'unknown remote pbm action')
        end
      end

      # @raise [ProconBypassMan::RemotePbmJobObject::ValidationError]
      # @param [Hash] data
      # @param [Symbol] process_to_execute どのプロセスで実行するか
      # @return [Void]
      def self.run_remote_pbm_job(data: , process_to_execute: )
        pbm_job_hash = data.dig("message")
        begin
          pbm_job_object = ProconBypassMan::RemotePbmJobObject.new(action: pbm_job_hash["action"],
                                                                      status: pbm_job_hash["status"],
                                                                      uuid: pbm_job_hash["uuid"],
                                                                      created_at: pbm_job_hash["created_at"],
                                                                      job_args: pbm_job_hash["args"])
          pbm_job_object.validate!
        rescue ProconBypassMan::RemotePbmJobObject::ValidationError => e
          ProconBypassMan::SendErrorCommand.execute(error: e)
          return
        end

        case process_to_execute
        when :master
          ProconBypassMan::RemoteAction::RemotePbmJob::RunRemotePbmJobDispatchCommand.execute(
            action: pbm_job_object.action,
            uuid: pbm_job_object.uuid,
            job_args: pbm_job_object.job_args
          )
        when :bypass
          ProconBypassMan::RemoteAction::QueueOverProcess.push(
            ProconBypassMan::RemoteAction::Task.new(pbm_job_object.action,
                                                   pbm_job_object.uuid,
                                                   pbm_job_object.job_args,
                                                   ProconBypassMan::RemoteAction::Task::TYPE_ACTION)
          )
        else
          ProconBypassMan::SendErrorCommand.execute(error: 'unknown process to execute')
        end
      end

      def self.run_remote_macro(data: )
        pbm_job_hash = data.dig("message")
        begin
          remote_action_object = ProconBypassMan::RemoteAction::RemoteActionObject.new(name: pbm_job_hash["name"],
                                                                                    uuid: pbm_job_hash["uuid"],
                                                                                    steps: pbm_job_hash["steps"])
          remote_action_object.validate!
        rescue ProconBypassMan::RemoteAction::RemoteActionObject::ValidationError => e
          ProconBypassMan::SendErrorCommand.execute(error: e)
          return
        end

        # TODO: インラインしたい
        ProconBypassMan::RemoteActionSender.execute(
          name: remote_action_object.name,
          uuid: remote_action_object.uuid,
          steps: remote_action_object.steps,
          type: ProconBypassMan::RemoteAction::Task::TYPE_MACRO,
        )
      end
    end
  end
end

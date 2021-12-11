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
              channel: CHANNEL, device_id: ProconBypassMan.device_id,
            }
          )
          client.connected { puts 'successfully connected.' }

          client.received do |data|
            pbm_job_hash = data["message"]
            pbm_job_object = ProconBypassMan::RemotePbmActionObject.new(action: pbm_job_hash["action"],
                                                                        status: pbm_job_hash["status"],
                                                                        uuid: pbm_job_hash["uuid"],
                                                                        created_at: pbm_job_hash["created_at"],
                                                                        job_args: pbm_job_hash["args"])
            puts data
            pbm_job_object.validate!
            ProconBypassMan::RunRemotePbmActionDispatchCommand.execute(action: pbm_job_object.action, uuid: pbm_job_object.uuid, job_args: pbm_job_object.job_args)
          rescue ProconBypassMan::RemotePbmActionObject::ValidationError => e
            ProconBypassMan::SendErrorCommand.execute(error: e)
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
          client.errored { |msg|  puts :errored; puts msg }
          client.pinged { |msg| puts :disconnected; puts msg }
        end
      end
    end
  end
end

module ProconBypassMan
  module Websocket
    module PbmJobClient
      CHANNEL = 'PbmJobChannel'

      def self.start!
        return unless ProconBypassMan.config.enable_ws?

        loop do
          Thread.start { run }.join
        rescue
          retry
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
          client.subscribed { |msg| puts({ event: :subscribed, msg: msg }) }

          client.received do |data|
            validate_and_run(data: data)
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

      # @raise [ProconBypassMan::RemotePbmActionObject::ValidationError]
      # @param [Hash] data
      # @return [Void]
      def self.validate_and_run(data: )
        ProconBypassMan.logger.debug { data }
        pbm_job_hash = data.dig("message")
        begin
          pbm_job_object = ProconBypassMan::RemotePbmActionObject.new(action: pbm_job_hash["action"],
                                                                      status: pbm_job_hash["status"],
                                                                      uuid: pbm_job_hash["uuid"],
                                                                      created_at: pbm_job_hash["created_at"],
                                                                      job_args: pbm_job_hash["args"])
          pbm_job_object.validate!
        rescue ProconBypassMan::RemotePbmActionObject::ValidationError => e
          raise
        end

        ProconBypassMan::RunRemotePbmActionDispatchCommand.execute(
          action: pbm_job_object.action,
          uuid: pbm_job_object.uuid,
          job_args: pbm_job_object.job_args
        )
      end
    end
  end
end

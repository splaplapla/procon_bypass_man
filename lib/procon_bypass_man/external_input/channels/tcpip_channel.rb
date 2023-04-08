module ProconBypassMan
  module ExternalInput
    module Channels
      class TCPIPChannel < Base
        class AppHandler < EventMachine::Connection
          @command_queue = Queue.new

          class << self
            attr_accessor :command_queue
          end

          def post_init
            ProconBypassMan.logger.debug { "A client has connected" }
          end

          def unbind
            ProconBypassMan.logger.debug { "A client has disconnected" }
          end

          # @return [String]
          def receive_data(data)
            case data
            when /^{/
              self.class.command_queue.push(data)
              send_data "OK\r\n"
            when /^\r\n/
              if self.class.command_queue.empty?
                send_data "EMPTY\r\n"
                return
              end

              data = self.class.command_queue.pop
              send_data "#{data}\r\n"
            else
              send_data "Unknown command\r\n"
            end
          end
        end

        def initialize(port: )
          @port = port
          super()

          # NOTE: masterプロセスで起動する
          Thread.start do
            # TODO: foreverが必要かも
            EventMachine.run do
              EventMachine.start_server '0.0.0.0', @port, AppHandler
            end
          end
        end

        # NOTE: bypassプロセスから呼ばれ、masterプロセスへ繋ぐ
        # @return [String, NilClass]
        def read
          @socket ||= TCPSocket.new('0.0.0.0', @port)
          read_command = "\r\n"
          @socket.write(read_command)
          response = @socket.gets&.strip
          # ProconBypassMan.logger.debug { "Received: #{response}" }

          case response
          when /^{/
            return response
          when /^EMPTY/, ''
            return nil
          else
            ProconBypassMan.logger.warn { "[ExternalInput][TCPIPChannel] Unknown response(#{response})" }
            return nil
          end
        rescue Errno::EPIPE => e
          @socket = nil
          sleep(10)
          ProconBypassMan.logger.error { "[ExternalInput][TCPIPChannel] Broken pipe!!!!!!!(e)" }
          retry
        rescue => e
          ProconBypassMan.logger.error { "[ExternalInput][TCPIPChannel] #{e} が起きました" }
        end
      end
    end
  end
end

module ProconBypassMan
  module ExternalInput
    module Channels
      class TCPIPChannel < Base
        class ShutdownSignal < StandardError; end

        class AppHandler < EventMachine::Connection
          @command_queue = Queue.new

          class << self
            attr_accessor :command_queue
          end

          def post_init
            ProconBypassMan.logger.info { "[ExternalInput][TCPIPChannel] A client has connected" }
          end

          def unbind
            ProconBypassMan.logger.info { "[ExternalInput][TCPIPChannel] A client has disconnected" }
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
          @server_thread = Thread.start do
            # foreverを使いたいけど、watchdog.active!が発動しなくて諦めた
            loop do
              EventMachine.run do
                EventMachine.start_server '0.0.0.0', @port, AppHandler
              end
            rescue ShutdownSignal
              begin
                EventMachine.stop
                EventMachine.release_machine
              rescue EventMachine::Error => e
                ProconBypassMan.logger.error { "Failed to stop EventMachine: #{e.message}" }
              end

              break
            rescue => e
              ProconBypassMan::SendErrorCommand.execute(error: "[ExternalInput][TCPIPChannel] #{e.message}(#{e})")
              sleep(5)
              retry
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
        rescue Errno::EPIPE, EOFError => e
          @socket = nil
          sleep(10)
          ProconBypassMan.logger.error { "[ExternalInput][TCPIPChannel] #{e.message}!!!!!!!(#{e})" }
          retry
        rescue => e
          ProconBypassMan.logger.error { "[ExternalInput][TCPIPChannel] #{e.message} が起きました(#{e})" }
          return nil
        end

        def shutdown
          @server_thread.raise(ShutdownSignal)
        end

        def alive_server?
          return false if not @server_thread.alive?

          begin
            TCPSocket.new('0.0.0.0', @port).close
          rescue Errno::ECONNREFUSED
            return false
          end

          true
        end
      end
    end
  end
end

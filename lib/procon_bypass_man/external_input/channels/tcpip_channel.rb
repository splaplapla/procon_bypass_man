module ProconBypassMan
  module ExternalInput
    module Channels
      class TCPIPChannel < Base
        class ShutdownSignal < StandardError; end

        class AppServer < SimpleTCPServer
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
          def receive_data(client, data)
            case data
            when /^{/
              self.class.command_queue.push(data)
              client.write("OK\n")
              return
            when /^\n/
              if self.class.command_queue.empty?
                client.write("EMPTY\n")
                return
              end

              data = self.class.command_queue.pop
              client.write("#{data}\n")
              return
            else
              client.write("Unknown command\n")
              return
            end
          end
        end

        def initialize(port: )
          @port = port
          super()

          @server = AppServer.new('0.0.0.0', @port)

          # NOTE: masterプロセスで起動する
          @server_thread = Thread.start do
            loop do
              @server.start_server
              @server.run
            rescue Errno::EPIPE, EOFError, Errno::ECONNRESET => e
              ProconBypassMan::SendErrorCommand.execute(error: "[ExternalInput][TCPIPChannel] #{e.message}(#{e})")
              sleep(5)

              @server.shutdown
              retry
            rescue ShutdownSignal => e
              ProconBypassMan::SendErrorCommand.execute(error: "[ExternalInput][TCPIPChannel] ShutdownSignalを受け取りました。終了します。")
              @server.shutdown
              break
            rescue => e
              ProconBypassMan::SendErrorCommand.execute(error: "[ExternalInput][TCPIPChannel] #{e.message}(#{e})")
              break
            end
          end
        end

        # NOTE: bypassプロセスから呼ばれ、masterプロセスへ繋ぐ
        # @return [String, NilClass]
        def read
          @socket ||= TCPSocket.new('0.0.0.0', @port)
          read_command = "\n"
          @socket.write(read_command)
          response = @socket.gets&.strip
          # ProconBypassMan.logger.debug { "Received: #{response}" }

          case response
          when /^{/
            return response
          when /^EMPTY/, ''
            return nil
          else
            ProconBypassMan.logger.warn { "[ExternalInput][TCPIPChannel] Unknown response(#{response}, codepoints: #{response.codepoints})" }
            return nil
          end
        rescue Errno::EPIPE, EOFError => e
          @socket = nil
          sleep(10)
          ProconBypassMan.logger.error { "[ExternalInput][TCPIPChannel] #{e.message}!!!!!!!(#{e})" }
          retry
        rescue => e
          @socket = nil
          ProconBypassMan.logger.error { "[ExternalInput][TCPIPChannel] #{e.message} が起きました(#{e})" }
          return nil
        end

        def shutdown
          ProconBypassMan.logger.info { "[ExternalInput][TCPIPChannel] shutdown" }
          @server_thread.raise(ShutdownSignal)
        end

        def alive_server?
          return false if not @server_thread.alive?

          begin
            TCPSocket.new('0.0.0.0', @port).close
          rescue Errno::ECONNREFUSED, Errno::ECONNRESET
            return false
          end

          true
        end
      end
    end
  end
end

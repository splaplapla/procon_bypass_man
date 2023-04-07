module ProconBypassMan
  module ExternalInput
    module Channels
      class TCPIPChannel < Base
        class TCPServer < EventMachine::Connection
          @@queue = Queue.new

          def post_init
            puts "A client has connected"
          end

          def unbind
            puts "A client has disconnected"
          end

          def receive_data(data)
            puts "#{data}を受け取ったよ(#{data.codepoints})"

            case data
            when /^{/
              @@queue.push(data)
              send_data "OK\r\n"
            when "\r\n"
              if @@queue.size.zero?
                send_data "EMPTY\r\n"
                return
              end

              data = @@queue.pop
              send_data "#{data}\r\n"
            else
              send_data "Unknown command\r\n"
            end
          end
        end

        def initialize(port: )
          super()

          Thread.start do
            ProconBypassMan::Websocket::Forever.run do
              EventMachine.run do
                EventMachine.start_server '0.0.0.0', port, EchoServer
              end
            end
          end
        end

        def read
          # TODO: masterプロセスへ繋ぐ
        end
      end
    end
  end
end

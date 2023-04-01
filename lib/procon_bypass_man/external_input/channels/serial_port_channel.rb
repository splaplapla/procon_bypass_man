module ProconBypassMan
  module ExternalInput
    module Channels
      class SerialPortChannel < Base
        attr_reader :serial_port

        # @param [String] device_path
        # @param [Integer] baud_rate
        def initialize(device_path: , baud_rate: 9600)
          super()
          # data_bitsあたりは必要があれば設定ができるようにしたいがよくわからないのでとりあえずnilを入れる
          data_bits = nil
          stop_bits = nil
          parity = nil
          @serial_port= SerialPort.new(device_path, baud_rate, data_bits, stop_bits, parity)
        end

        # @return [String, NilClass]
        def read
          # NOTE: 改行コードが来るまでバッファリングが必要？
          @serial_port.read_nonblock(1024)
        rescue ::IO::EAGAINWaitReadable
          nil
        end
      end
    end
  end
end

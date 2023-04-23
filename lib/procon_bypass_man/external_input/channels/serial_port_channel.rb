module ProconBypassMan
  module ExternalInput
    module Channels
      class SerialPortChannel < Base
        attr_reader :serial_port

        # @param [String] device_path
        # @param [Integer] baud_rate
        def initialize(device_path: , baud_rate: 9600)
          require 'serialport'

          super()
          # data_bitsあたりは必要があれば設定ができるようにしたいがよくわからないのでとりあえずnilを入れる
          data_bits = 8
          stop_bits = 1
          parity = SerialPort::NONE
          @serial_port = SerialPort.new(device_path, baud_rate, data_bits, stop_bits, parity)
        end

        # @return [String, NilClass]
        # NOTE: この実装では、::IO::EAGAINWaitReadableを実質的な終端として扱っているので、高速に書き込みがされると取りこぼす可能性がある.
        # NOTE: read_nonblockでバッファから読み出すとき、バッファが空になるまでは::IO::EAGAINWaitReadableが起きない前提で実装している.
        # NOTE: 取りこぼししないよう精度を上げるには、終端文字が来るまで1文字ずつ読む必要があるがパフォーマンスが犠牲になってしまう. この対策をするには、bypass処理の開始で非同期に1文字ずつ読み込むことをすると多少マシになるはず
        def read
          buffer = ''
          loop do
            begin
              buffer += @serial_port.read_nonblock(1024) || ''
            rescue ::IO::EAGAINWaitReadable
              break
            end
          end

          return nil if buffer.empty?

          # NOTE: 高速に書き込まれた場合、複数のチャンクを含む可能性があるので、最初だけを切り取る
          chunks = buffer.split("\n")
          if(chunks.size > 1)
            ProconBypassMan::SendErrorCommand.execute(
              error: "[ExternalInput] シリアルポートから読み込んだchunkが複数あります. 高い書き込み頻度に耐えられていないので実装を見直してください。 (chunks.size: #{chunks.size})"
            )
          end
          chunks.first
        end

        def shutdown
          # no-op
        end

        def display_name_for_boot_message
          'SerialPort'
        end
      end
    end
  end
end

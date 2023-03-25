module ProconBypassMan
  module ExternalInput
    module Channels
      class SerialPort < ::ProconBypassMan::ExternalInput::Channels::Base
        # @param [String] device_path
        # @param [Integer] baud_rate
        def initialize(device_path: , baud_rate: 9600)
          super
          data_bits = nil
          stop_bits = nil
          parity = nil
          @device = SerialPort.new(device_path, baud_rate, data_bits, stop_bits, parity)
        end

        # @return [SerialPort]
        def device
          @device
        end
      end
    end
  end
end
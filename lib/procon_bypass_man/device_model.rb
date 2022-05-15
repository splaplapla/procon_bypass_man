class ProconBypassMan::DeviceModel
  # @param [File] device
  def initialize(device)
    @device = device
  end

  # @param [String] raw_data
  def send(raw_data)
    @device.write_nonblock(raw_data)
  end

  # @raise [IO::EAGAINWaitReadable]
  # @return [String]
  def non_blocking_read
    @device.read_nonblock(64)
  end
end

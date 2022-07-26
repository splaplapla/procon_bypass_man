class ProconBypassMan::DeviceConnection::OutputReport
  def initialize(binary: )
    @binary = binary
  end

  def disable_if_rubble_data
    @binary[11] = "\x00"
  end

  def binary
    @binary
  end
end

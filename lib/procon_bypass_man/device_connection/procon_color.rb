class ProconBypassMan::DeviceConnection::ProconColor
  # NOTE: [Body, Buttons, Left Grip, Right Grip] RGB
  COLOR_TABLE = {
    red:    ['ff 00 00', 'ff ff ff', 'ff 00 00', 'ff 00 00'],
    blue:   ['00 00 ff', 'ff ff ff', '00 00 ff', '00 00 ff'],
    yellow: ['ff ff 00', 'ff ff ff', 'ff ff 00', 'ff ff 00'],
    green:  ['00 ff 00', 'ff ff ff', '00 ff 00', '00 ff 00'],
    pink:   ['ff 00 ff', 'ff ff ff', 'ff 00 ff', 'ff 00 ff'],
    cyan:   ['00 ff ff', 'ff ff ff', '00 ff ff', '00 ff ff'],
    white:  ['ff ff ff', '00 00 00', 'ff ff ff', 'ff ff ff'],
  }

  BYTE_POSITION = 20...(20+(3*4))

  attr_accessor :name

  # @param [Symbol] color_name
  # @return [void]
  def initialize(color_name)
    self.name = color_name.to_sym
  end

  # @return [String]
  def to_bytes
    [COLOR_TABLE[self.name].join.gsub(/[,\s]/, '')].pack('H*')
  end

  # @return [Range]
  def byte_position
    BYTE_POSITION
  end

  # @return [Boolean]
  def valid?
    !!COLOR_TABLE[self.name]
  end
end

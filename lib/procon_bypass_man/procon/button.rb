class ProconBypassMan::Procon::Button
  attr_accessor :byte_position, :bit_position

  def initialize(key)
    b = ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP[key] or raise("undefined button")
    self.byte_position = b[:byte_position]
    self.bit_position = b[:bit_position]
  end
end

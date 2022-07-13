class ProconBypassMan::Bypass::BypassValue < Struct.new(:binary)
  def to_text
    return unless binary
    binary.unpack.first
  end
end

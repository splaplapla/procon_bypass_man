class ProconBypassMan::Procon::Rumbler
  def self.monitor
    @@must_rumble = false
    return yield
  end

  def self.rumble!
    @@must_rumble = true
  end

  def self.must_rumble?
    @@must_rumble
  end

  def self.binary
    ["100c00000000" + "00001010"].pack("H*")
  end
end

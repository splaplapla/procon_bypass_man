class ProconBypassMan::Procon
  #3)  ZR	R	SR(right)	SL(right)	A	B	X	Y
  #4)  Grip	(none)	Cap	Home	ThumbL	ThumbR	+	-
  #5)  ZL	L	SL(left)	SR(left)	Left	Right	Up	Down
  def initialize(binary)
    @binary = binary
  end

  def pushed_zr?
    @binary[3].unpack("H*").first.to_i(16).to_s(2).reverse[7] == "1"
  end

  def pushed_down?
    @binary[5].unpack("H*").first.to_i(16).to_s(2).reverse[0] == "1"
  end

  def unpush(button)
  end
end

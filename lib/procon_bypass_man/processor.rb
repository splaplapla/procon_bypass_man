class ProconBypassMan::Processor
  # @return [String] binary
  def initialize(binary)
    @binary = binary
  end

  # @return [String]
  def process
    binding.pry
    # 入力データ
    if @binary[0] == "\x30".b
    end

    # ZR	R	SR(right)	SL(right)	A	B	X	Y
    bit3 = @binary[3]
    if bit3.unpack("H*").first.to_i(16).to_s(2).reverse[7] == "1"
      puts "ZRが押されています"
    end

    # Grip	(none)	Cap	Home	ThumbL	ThumbR	+	-
    bit4 = @binary[4]
    # ZL	L	SL(left)	SR(left)	Left	Right	Up	Down
    bit5 = @binary[5]
    if bit5.unpack("H*").first.to_i(16).to_s(2).reverse[0] == "1"
      puts "downが押されています"
    end

    @binary
  end
end

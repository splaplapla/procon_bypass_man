class ProconBypassMan::Procon
  KEY_ZR = 128
  KEY_DOWN = 1

  @@status = {}
  #3)  ZR	R	SR(right)	SL(right)	A	B	X	Y
  #4)  Grip	(none)	Cap	Home	ThumbL	ThumbR	+	-
  #5)  ZL	L	SL(left)	SR(left)	Left	Right	Up	Down
  def initialize(binary)
    @binary = binary
  end

  def self.input(binary)
    new(binary)
  end

  def status
    @@status || {}
  end

  # ここで入力を書き換える
  def apply!
    # changes.each do |key, values|
    # end
    if pushed_zr?
      @@status[:zr] = !@@status[:zr]
    else
      @@status[:zr] = false
    end

    if pushed_down?
      @@status[:down] = !@@status[:down]
    else
      @@status[:down] = false
    end

    @@status
  end

  def changes
    c = []
    c << { zr: [@@status[:zr], pushed_zr?] }
    c << { down: [@@status[:down], pushed_down?] }
    c.select { |_key, values| values.first != values.last }
  end

  def pushed_zr?
    @binary[3].unpack("H*").first.to_i(16).to_s(2).reverse[7] == "1"
  end

  def pushed_down?
    @binary[5].unpack("H*").first.to_i(16).to_s(2).reverse[0] == "1"
  end

  def to_binary
    if !@@status[:zr]
      binary3 = @binary[3].unpack("H*").first.to_i(16) - KEY_ZR
      @binary[3] = [binary3.to_s(16)].pack("H*")
    end

    if !@@status[:down]
      binary5 = @binary[5].unpack("H*").first.to_i(16) - KEY_DOWN
      @binary[5] = [binary5.to_s(16)].pack("H*")
    end

    @binary
  end
end

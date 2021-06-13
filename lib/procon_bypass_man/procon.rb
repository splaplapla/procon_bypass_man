class ProconBypassMan::Procon
  BYTES_MAP = {
    0 => nil,
    1 => nil,
    2 => nil,
    3 => [:zr, :r, :sr, :sl, :a, :b, :x, :y],
    4 => [:grip, nil, :cap, :home, :thumbl, :thumbr, :plus, :minus],
    5 => [:zl, :l, :sl, :sr, :left, :right, :up, :down],
  },

  # TODO BYTES_MAPから組み立てる
  BUTTONS_MAP = {
    zr: { byte_position: 3, bit_position: 7 },
    down: { byte_position: 5, bit_position: 0 }
  }

  @@status = {}

  #3)  ZR	R	SR(right)	SL(right)	A	B	X	Y
  #4)  Grip	(none)	Cap	Home	ThumbL	ThumbR	+	-
  #5)  ZL	L	SL(left)	SR(left)	Left	Right	Up	Down
  def initialize(binary)
    @binary = binary.dup
  end

  def self.input(binary)
    new(binary)
  end

  def status
    @@status
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
    pushed_button?(:zr)
  end

  def pushed_down?
    pushed_button?(:down)
  end

  def to_binary
    if pushed_zr? && !@@status[:zr]
      d_from_binary3 = @binary[3].unpack("H*").first.to_i(16) - 2**BUTTONS_MAP[:zr][:bit_position]
      @binary[3] = ["%02X" % d_from_binary3.to_s].pack("H*")
    end

    if pushed_down? && !@@status[:down]
      d_from_binary5 = @binary[5].unpack("H*").first.to_i(16) - 2**BUTTONS_MAP[:down][:bit_position]
      @binary[5] = ["%02X" % d_from_binary5.to_s].pack("H*")
    end

    @binary
  end

  private

  def pushed_button?(button)
    @binary[
      BUTTONS_MAP[button][:byte_position]
    ].unpack("H*").first.to_i(16).to_s(2).reverse[
      BUTTONS_MAP[button][:bit_position]
    ] == '1'
  end
end

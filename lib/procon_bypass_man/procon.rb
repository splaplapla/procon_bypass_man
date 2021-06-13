class ProconBypassMan::Procon
  #3)  ZR	R	SR(right)	SL(right)	A	B	X	Y
  #4)  Grip	(none)	Cap	Home	ThumbL	ThumbR	+	-
  #5)  ZL	L	SL(left)	SR(left)	Left	Right	Up	Down
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
  @@compiled = false

  attr_accessor :binary

  def self.compile!
    return if @@compiled
    flip_buttons.each do |button|
      define_method "pushed_#{button}?" do
        pushed_button?(button)
      end
    end
    @@compiled = true
  end

  # TODO plugin経由で差し込めるようにする
  def self.flip_buttons
    [:zr, :down]
  end

  def self.input(binary)
    new(binary)
  end

  def initialize(binary)
    self.class.compile! unless @@compiled
    self.binary = binary.dup
  end

  def status
    @@status
  end

  # ここで入力を書き換える
  def apply!
    flip_buttons.each do |button|
      if pushed_button?(button)
        status[button] = !status[button]
      else
        status[button] = false
      end
    end

    status
  end

  def to_binary
    flip_buttons.each do |button|
      if pushed_button?(button) && !status[button]
        byte_position = BUTTONS_MAP[button][:byte_position]
        value = binary[byte_position].unpack("H*").first.to_i(16) - 2**BUTTONS_MAP[button][:bit_position]
        binary[byte_position] = ["%02X" % value.to_s].pack("H*")
      end
    end
    binary
  end

  private

  def pushed_button?(button)
    binary[
      BUTTONS_MAP[button][:byte_position]
    ].unpack("H*").first.to_i(16).to_s(2).reverse[
      BUTTONS_MAP[button][:bit_position]
    ] == '1'
  end

  def flip_buttons
    self.class.flip_buttons
  end
end

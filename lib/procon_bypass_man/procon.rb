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
    l: { byte_position: 5, bit_position: 6 },
    r: { byte_position: 3, bit_position: 6 },
    zr: { byte_position: 3, bit_position: 7 },
    zl: { byte_position: 5, bit_position: 7 },
    up: { byte_position: 5, bit_position: 1 },
    down: { byte_position: 5, bit_position: 0 },
    right: { byte_position: 5, bit_position: 2 },
    left: { byte_position: 5, bit_position: 3 },
  }

  @@status = {}
  @@current_layer = :up
  @@layers_map = {
    up: { flip_buttons: [:zr, :down] },
    down: { flip_buttons: [:zr, :down] },
    right: { flip_buttons: [] },
    left: { flip_buttons: [] },
  }
  @@compiled = false

  attr_accessor :binary

  def self.compile!
    return if @@compiled
    BUTTONS_MAP.each do |button, value|
      define_method "pushed_#{button}?" do
        pushed_button?(button)
      end
    end
    @@compiled = true
  end

  # TODO plugin経由で差し込めるようにする
  def self.flip_buttons
    @@layers_map[@@current_layer][:flip_buttons]
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

  def next_layer
    case
    when pushed_up?
      :up
    when pushed_right?
      :right
    when pushed_left?
      :left
    when pushed_down?
      :down
    else
      pp "おかしい"
      :up
    end
  end

  def change_layer?
    (pushed_r? && pushed_l? && pushed_zr? && pushed_zl?) || \
      (pushed_up? || pushed_right? || pushed_left? || pushed_down?)
  end

  def apply!
    if change_layer?
      @@current_layer = next_layer
    end

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

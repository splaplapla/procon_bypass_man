class ProconBypassMan::Procon::ButtonCollection
  class Button
    attr_accessor :byte_position, :bit_position
    def initialize(key)
      b = BUTTONS_MAP[key] or raise("undefined button")
      self.byte_position = b[:byte_position]
      self.bit_position = b[:bit_position]
    end
  end

  #3)  ZR	R	SR(right)	SL(right)	A	B	X	Y
  #4)  Grip	(none)	Cap	Home	ThumbL	ThumbR	+	-
  #5)  ZL	L	SL(left)	SR(left)	Left	Right	Up	Down
  #6)  analog[0]
  #7)  analog[1]
  #8)  analog[2]
  #9)  analog[3]
  #a)  analog[4]
  #b)  analog[5]
  BYTES_MAP = {
    0 => nil,
    1 => nil,
    2 => nil,
    3 => [:zr, :r, :sr, :sl, :a, :b, :x, :y],
    4 => [:grip, :_undefined_key, :cap, :home, :thumbl, :thumbr, :plus, :minus],
    5 => [:zl, :l, :sl, :sr, :left, :right, :up, :down],
  }.freeze

  BUTTONS_MAP = BYTES_MAP.reduce({}) { |acc, value|
    next acc if value[1].nil?
    value[1].reverse.each.with_index do |button, index|
      acc[button] = { byte_position: value[0], bit_position: index }
    end
    acc
  }.freeze
  BUTTONS = ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.keys.freeze

  def self.load(button_key)
    Button.new(button_key)
  end
end

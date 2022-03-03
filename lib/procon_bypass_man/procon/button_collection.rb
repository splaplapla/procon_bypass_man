class ProconBypassMan::Procon::ButtonCollection
  # https://github.com/dekuNukem/Nintendo_Switch_Reverse_Engineering/blob/ac8093c84194b3232acb675ac1accce9bcb456a3/bluetooth_hid_notes.md
  #0) Input report ID
  #1) Timer. Increments very fast. Can be used to estimate excess Bluetooth latency.
  #2 high nibble) Battery level. 8=full, 6=medium, 4=low, 2=critical, 0=empty. LSB=Charging.
  #2 low nibble) Connection info. (con_info >> 1) & 3 - 3=JC, 0=Pro/ChrGrip. con_info & 1 - 1=Switch/USB powered.
  #3)  ZR	R	SR(right)	SL(right)	A	B	X	Y
  #4)  Grip	(none)	Cap	Home	ThumbL	ThumbR	+	-
  #5)  ZL	L	SL(left)	SR(left)	Left	Right	Up	Down
  #6)  analog[0] Left analog stick data
  #7)  analog[1] Left analog stick data
  #8)  analog[2] Left analog stick data
  #9)  analog[3] Right analog stick data
  #a)  analog[4] Right analog stick data
  #b)  analog[5] Right analog stick data
  BYTES_MAP = {
    0 => nil,
    1 => nil,
    2 => nil,
    3 => [:zr, :r, :sr, :sl, :a, :b, :x, :y],
    4 => [:grip, :_undefined_key, :cap, :home, :thumbl, :thumbr, :plus, :minus],
    5 => [:zl, :l, :sl, :sr, :left, :right, :up, :down],
    6 => [],
    7 => [],
    8 => [],
  }.freeze

  BUTTONS_MAP = BYTES_MAP.reduce({}) { |acc, value|
    next acc if value[1].nil?
    value[1].reverse.each.with_index do |button, index|
      next(acc) if button == :grip || button == :_undefined_key
      acc[button] = { byte_position: value[0], bit_position: index }
    end
    acc
  }.freeze

  BUTTONS = ProconBypassMan::Procon::ButtonCollection::BUTTONS_MAP.keys.freeze

  LEFT_ANALOG_STICK = { byte_position: 6..8 }
end

class ProconBypassMan::Procon
  require "procon_bypass_man/procon/layer_changeable"

  include LayerChangeable

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
  }

  BUTTONS_MAP = BYTES_MAP.reduce({}) { |acc, value|
    next acc if value[1].nil?
    value[1].reverse.each.with_index do |button, index|
      acc[button] = { byte_position: value[0], bit_position: index }
    end
    acc
  }

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

  def self.reset_cvar!
    @@status = {}
    @@auto_mode_sequence = 0
    @@current_layer_key = :up
    @@compiled = false
    @@on_going_macro = nil
  end
  reset_cvar!

  def self.input(binary)
    new(binary)
  end

  def initialize(binary)
    self.class.compile! unless @@compiled
    self.binary = binary.dup
  end

  def status; @@status; end
  def on_going_macro; @@on_going_macro; end
  def current_layer_key; @@current_layer_key; end

  def apply!
    # layer変更中はニュートラルにする
    if change_layer?
      @@current_layer_key = next_layer_key if pushed_next_layer?
      self.binary = [ProconBypassMan::Procon::Data::NO_ACTION].pack("H*")
      return
    end

    if @@on_going_macro.nil?
      current_layer.macros.each do |macro_name, options|
        if options[:if_pushed].all? { |b| pushed_button?(b) }
          @@on_going_macro = ProconBypassMan::MacroRegistry.load(macro_name)
        end
      end
    end

    case
    when current_layer.mode == :auto
      data = ProconBypassMan::Procon::Data::MEANINGLESS[@@auto_mode_sequence]
      if data.nil?
        @@auto_mode_sequence = 0
        data = ProconBypassMan::Procon::Data::MEANINGLESS[@@auto_mode_sequence]
      end
      @@auto_mode_sequence += 1
      auto_binary = [data].pack("H*")
      self.binary[3] = auto_binary[3]
      self.binary[4] = auto_binary[4]
      self.binary[5] = auto_binary[5]
      self.binary[6] = auto_binary[6]
      self.binary[7] = auto_binary[7]
      self.binary[8] = auto_binary[8]
      self.binary[9] = auto_binary[9]
      self.binary[10] = auto_binary[10]
      self.binary[11] = auto_binary[11]
      return
    else
      consumed_channel_table = {}
      current_layer.flip_buttons.each do |button, options|
        unless options[:if_pushed]
          status[button] = !status[button]
          next
        end

        if options[:if_pushed] && options[:if_pushed].all? { |b| pushed_button?(b) }
          # 同じチャンネルで操作済みのときはステータスを更新しない
          next if consumed_channel_table[options[:channel]]
          status[button] = !status[button]
          consumed_channel_table[options[:channel]] = true if options[:channel]
        else
          status[button] = false
        end
      end
    end

    status
  end

  def to_binary
    if @@on_going_macro
      step = @@on_going_macro.next_step
      if step.nil?
        @@on_going_macro = nil
        return(binary)
      end
      [ProconBypassMan::Procon::Data::NO_ACTION.dup].pack("H*").tap do |no_action_binary|
        byte_position = BUTTONS_MAP[step][:byte_position]
        value = 2**BUTTONS_MAP[step][:bit_position]
        no_action_binary[byte_position] = ["%02X" % value.to_s].pack("H*")
        self.binary[3] = no_action_binary[3]
        self.binary[4] = no_action_binary[4]
        self.binary[5] = no_action_binary[5]
      end
      return binary
    end

    current_layer.flip_buttons.each do |button, options|
      # 何もしないで常に連打
      if !options[:if_pushed] && status[button]
        byte_position = BUTTONS_MAP[button][:byte_position]
        value = binary[byte_position].unpack("H*").first.to_i(16) + 2**BUTTONS_MAP[button][:bit_position]
        binary[byte_position] = ["%02X" % value.to_s].pack("H*")
        next
      end

      # 押している時だけ連打
      if options[:if_pushed] && options[:if_pushed].all? { |b| pushed_button?(b) }
        if !status[button]
          byte_position = BUTTONS_MAP[button][:byte_position]
          value = binary[byte_position].unpack("H*").first.to_i(16) - 2**BUTTONS_MAP[button][:bit_position]
          binary[byte_position] = ["%02X" % value.to_s].pack("H*")
        end
        if options[:force_neutral] && pushed_button?(options[:force_neutral])
          button = options[:force_neutral]
          byte_position = BUTTONS_MAP[button][:byte_position]
          value = binary[byte_position].unpack("H*").first.to_i(16) - 2**BUTTONS_MAP[button][:bit_position]
          binary[byte_position] = ["%02X" % value.to_s].pack("H*")
        end
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
end

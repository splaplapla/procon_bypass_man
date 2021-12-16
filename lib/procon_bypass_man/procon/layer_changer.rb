class ProconBypassMan::Procon::LayerChanger
  def initialize(binary: )
    @procon_reader = ProconBypassMan::ProconReader.new(binary: binary).freeze
  end

  # @return [Symbol]
  def next_layer_key
    case
    when pressed?(button: :up)
      :up
    when pressed?(button: :right)
      :right
    when pressed?(button: :left)
      :left
    when pressed?(button: :down)
      :down
    else
      ProconBypassMan.logger.warn("next_layer_key is unknown")
      :up
    end
  end

  # @return [Boolean]
  def change_layer?
    if ProconBypassMan::ButtonsSettingConfiguration.instance.prefix_keys.empty?
      raise "prefix_keysが未設定です"
    end
    ProconBypassMan::ButtonsSettingConfiguration.instance.prefix_keys.map { |b| pressed?(button: b) }.all?
  end

  # @return [Boolean]
  def pressed_next_layer?
    change_layer? && (pressed?(button: :up) || pressed?(button: :right) || pressed?(button: :left) || pressed?(button: :down))
  end

  # @return [Boolean]
  def pressed?(button: )
    @procon_reader.pressing.include?(button)
  end
end

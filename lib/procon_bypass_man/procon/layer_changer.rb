# frozen_string_literal: true

class ProconBypassMan::Procon::LayerChanger
  # @param [ProconBypassMan::Domains::ProcessingProconBinary] binary
  def initialize(binary: )
    @procon_reader = binary.to_procon_reader
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
    if ProconBypassMan.buttons_setting_configuration.prefix_keys.empty?
      ProconBypassMan.cache.fetch key: 'unknown prefix_keys', expires_in: 60 do
        warn "prefix_keysが未設定です"
      end
      return false
    end
    
    ProconBypassMan.buttons_setting_configuration.prefix_keys.map { |b| pressed?(button: b) }.all?
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

module ProconBypassMan::Procon::LayerChangeable
  def next_layer_key
    case
    when pressed_up?
      :up
    when pressed_right?
      :right
    when pressed_left?
      :left
    when pressed_down?
      :down
    else
      pp "おかしい"
      :up
    end
  end

  def change_layer?
    if ProconBypassMan::Configuration.instance.prefix_keys.empty?
      raise "prefix_keysが未設定です"
    end
    ProconBypassMan::Configuration.instance.prefix_keys.map { |b| pressed_button?(b) }.all?
  end

  def pressed_next_layer?
    change_layer? && (pressed_up? || pressed_right? || pressed_left? || pressed_down?)
  end
end

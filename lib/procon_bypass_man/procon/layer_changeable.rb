module ProconBypassMan::Procon::LayerChangeable
  def next_layer_key
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
    if ProconBypassMan::Configuration.instance.prefix_keys.empty?
      raise "prefix_keysが未設定です"
    end
    ProconBypassMan::Configuration.instance.prefix_keys.map { |b| pushed_button?(b) }.all?
  end

  def pushed_next_layer?
    change_layer? && (pushed_up? || pushed_right? || pushed_left? || pushed_down?)
  end
end

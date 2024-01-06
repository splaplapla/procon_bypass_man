# setting.yamlから設定される値。設定ファイルを再読み込みするとすべて消える
class ProconBypassMan::EphemeralConfiguration
  KEYS = [
    :enable_rumble_on_layer_change,
    :recognized_procon_color,
  ].freeze

  attr_accessor(*KEYS)

  def reset!
    KEYS.each do |key|
      self.send("#{key}=", nil)
    end
  end
end

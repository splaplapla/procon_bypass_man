
# setting.yamlから設定される値。設定ファイルを再読み込みするとすべて消える
class ProconBypassMan::EphemeralConfiguration
  attr_accessor :enable_rumble_on_layer_change

  def reset!
    self.enable_rumble_on_layer_change = false
  end
end

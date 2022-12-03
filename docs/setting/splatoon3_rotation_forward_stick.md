# スプラトゥーン3: 左スティック1回転 マクロの設定方法

* procon_bypass_man: 0.3.4以上が必要です
* このマクロは、左スティックを高速に1回転をします


https://user-images.githubusercontent.com/1664497/205416889-d458668e-ab46-4867-890c-ce32ff467128.mp4


## 設定例
```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]
  install_macro_plugin(ProconBypassMan::Plugin::Splatoon2::Macro::RotationLeftStick)

  layer :up do
    macro ProconBypassMan::Plugin::Splatoon3::Macro::RotationLeftStick, if_pressed: [:left]
  end
```

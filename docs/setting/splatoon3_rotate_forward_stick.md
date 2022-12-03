# スプラトゥーン3: 左スティック1回転 マクロの設定方法

* procon_bypass_man: 0.3.4以上が必要です
* このマクロは、左スティックを高速に1回転をします

## 設定例
```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]
  install_macro_plugin(ProconBypassMan::Plugin::Splatoon2::Macro::ForwardIkarole)

  layer :up do
    macro ProconBypassMan::Plugin::Splatoon3::Macro::ForwardIkarole, if_pressed: [:left]
  end
```

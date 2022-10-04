# スプラトゥーン2: イカロール マクロの設定方法

* procon_bypass_man: 0.3.0以上が必要です
* このマクロは、右から上へ高速にスティックを入れることでイカロールを行います

## 設定例1
```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]

  layer :up do
    open_macro :forward_ikarole, steps: [:forward_ikarole1], if_pressed: [:thumbl], force_neutral: []
  end
```

## 設定例2
pluginとして登録してあるので、 `macro` を使っても同じことができます。

```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]

  install_macro_plugin(ProconBypassMan::Plugin::Splatoon2::Macro::ForwardIkarole)

  layer :up do
    macro ProconBypassMan::Plugin::Splatoon2::Macro::ForwardIkarole, if_pressed: [:thumbl], force_neutral: []
  end
```

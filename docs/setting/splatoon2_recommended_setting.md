# スプラトゥーン2: おすすめの設定
## 1 全般
### 1.1 デスしてから最速スパジャンのためのAボタン連打

`flip :a, if_pressed: [:a]`  
Aボタンを連打にします。復帰してから最速で前線復帰ができます

### 1.2 簡単スニーキング

ボタンを押している間は、水飛沫のたたないスニーキングの感度まで調整することができます。  
[設定方法](/docs/setting/left-analogstick-cap.md)

### 1.3 ナイス玉連打

`flip :down, if_pressed: :down`  
十字キーの下ボタンは常に連打にしておくとナイス玉が来たときに楽です。

### 1.4 最速スーパージャンプ

```
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey

layer :up do
  macro ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn, if_pressed: [:y, :b, :down]
  macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey, if_pressed: [:y, :b, :up]
  macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey, if_pressed: [:y, :b, :right]
  macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey, if_pressed: [:y, :b, :left]
end
```

マップを開かずにジャンプができます。トリガーは自由に設定できます。

## 2 武器に特化した設定
### 2.1 パブロ向け

`flip :zr, if_pressed: :zr, force_neutral: :zl`  
zrを連打にします。`force_neutral: :zl` というオプションをつけることで、ZRを押している間はZLを押しても無視されるようになります。パブロでは意味がありませんが、シューターだと煽りのような動作を抑制することができます。

### 2.2 ボトルガイザー(フォイル)向け

バブル即割のマクロがあります。
[設定方法](/docs/setting/splatoon2_macro_sokuwari_bubble.md)

## 3 設定例
### 3.1 シンプルなパブロ向け

* ZRボタン, ZLボタン, Lボタンを同時押しながら十字キーを押すとレイヤーを切り替える
* ナイス玉が来たときにゲージを貯めるために十字キーの下を連打
* 復帰から最速ジャンプのためにAボタンを連打
* 筆を振るためにZRボタンを連打
* 筆ダッシュをするためにLボタンをZRボタンに変更

```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]

  layer :up do
    flip :zr, if_pressed: :zr, force_neutral: :zl
    flip :a, if_pressed: [:a]
    flip :down, if_pressed: :down
    remap :l, to: :zr
  end

  layer :right do
  end

  layer :left do
  end

  layer :down do
  end
```

### 3.2 全部盛り

* ZRボタン, ZLボタン, Lボタンを同時押しながら十字キーを押すとレイヤーを切り替える
* ナイス玉が来たときにゲージを貯めるために十字キーの下を連打
* 筆を振るためにZRボタンを連打
* 復帰から最速ジャンプのためにAボタンを連打
* YボタンとBボタンと十字キーの上を同時に押したときに、マップ開いた時の↑に設定されている味方にスーパージャンプ
* YボタンとBボタンと十字キーの左を同時に押したときに、マップ開いた時の←に設定されている味方にスーパージャンプ
* YボタンとBボタンと十字キーの右を同時に押したときに、マップ開いた時の→に設定されている味方にスーパージャンプ
* YボタンとBボタンと十字キーの下を同時に押したときに、リスポーンにスーパージャンプ
* ZLボタンと十字キーの右ボタンを同時に、バブル即割を発動
* 筆ダッシュをするためにLボタンをZRボタンに変更
* ZLボタンとAボタンを同時に押したときにスニーキング

```yaml
version: 1.0
setting: |-
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb

  prefix_keys_for_changing_layer [:zr, :zl, :l]
  set_neutral_position 2100, 2000

  layer :up do
    flip :zr, if_pressed: :zr, force_neutral: :zl
    flip :a, if_pressed: [:a]
    flip :down, if_pressed: :down

    macro ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn, if_pressed: [:y, :b, :down]
    macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey, if_pressed: [:y, :b, :up]
    macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey, if_pressed: [:y, :b, :right]
    macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey, if_pressed: [:y, :b, :left]
    macro ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb, if_pressed: [:zl, :right]

    remap :l, to: :zr
    left_analog_stick_cap cap: 1100, if_pressed: [:zl, :a], force_neutral: :a
  end

  layer :right do
  end

  layer :left do
  end

  layer :down do
  end
```

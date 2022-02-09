# スプラトゥーン2: おすすめの設定
## 全般
### 簡単スニーキング

ボタンを押している間は、水飛沫のたたないスニーキングの感度まで調整することができます。  
[設定方法](/docs/setting/left-analogstick-cap.md)

### ナイス玉連打

`flip :down, if_pressed: :down`  
十字キーの下ボタンは常に連打にしておくとナイス玉が来たときに楽です。

### マクロでスーパージャンプ

```
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey

layer :up, mode: :manual do
  macro ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn, if_pressed: [:y, :b, :down]
  macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey, if_pressed: [:y, :b, :up]
  macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey, if_pressed: [:y, :b, :right]
  macro ProconBypassMan::Plugin::Splatoon2::Macro::JumpToLeftKey, if_pressed: [:y, :b, :left]
end
```

リスポーンや味方にスーパージャンプするマクロがあります。トリガーは自由に設定できます。

## 武器に特化した設定
### パブロ向け

`flip :zr, if_pressed: :zr, force_neutral: :zl`  
zrを連打にします。`force_neutral: :zl` というオプションをつけることで、ZRを押している間はZLを押しても無視されるようになります。パブロでは意味がありませんが、シューターだと煽りのような動作を抑制することができます。

### ボトルガイザー(フォイル)向け

バブル即割のマクロがあります。
[設定方法](/docs/setting/splatoon2_macro_sokuwari_bubble.md)

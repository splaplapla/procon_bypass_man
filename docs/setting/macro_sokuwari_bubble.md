# バブル即割(スプラッシュボム)マクロの設定方法
* procon_bypass_man: 0.1.18以上が必要です
* このマクロは、バブルの1個目のみを即割します

## 1. install_macro_pluginで即割マクロを有効化します
* `install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb` と書きます
* これを記述することで、layer内で呼び出せるようになります

## 2. どのlayerで発動するかを宣言します
* `macro ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb, if_pressed: [:zl, :right]`
  * `if_pressed` がどのボタンを押したときにこのマクロが発動するかの設定です
  * この場合は、ZLと十字キーの左を同時すると、このマクロが発動します

## 3. 設定を反映させる
* 上記の記述を加えたsetting.ymlを起動中のprocon_bypass_manプロセスで読み込むには、プロセスにその旨を伝える必要があります
  * ラズベリーパイを再起動して、プロセスを立ち上げ直す、でも目的は達成できますが、もっと簡単にsetting.ymlを再読み込みする必要があります
* 書き換えたsetting.ymlを、起動中のprocon_bypass_manプロセスへ即時反映するには、procon_bypass_manプロセスを動かしたまま、別のshellから 以下をを実行してください
  * setting.ymlのシンタックスが正しければ、switchとの接続が継続したままsetting.ymlの内容を読み込んでいるはずです

## まとめ
* `install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb`, `macro ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb, if_pressed: [:zl, :right]` の二つを記述するだけです。


## 設定例1
```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb

  layer :up, mode: :manual do
    macro ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb, if_pressed: [:zl, :right]
  end
```


## 設定例2
* `open_macro` キーワードを使っても同じことが実行可能です。
* この場合は、 `install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::SokuwariForSplashBomb` が不要です。

```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]

  layer :up, mode: :manual do
    open_macro :sokuwari, steps: [:toggle_r_for_0_2sec, :toggle_thumbr_for_0_14sec, :toggle_thumbr_and_toggle_zr_for_0_34sec, :toggle_r_for_1sec], if_pressed: [:zl, :right]
  end
```

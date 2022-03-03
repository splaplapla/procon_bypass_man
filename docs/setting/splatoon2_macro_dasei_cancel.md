# スプラトゥーン2: 惰性キャンセル マクロの設定方法

* procon_bypass_man: 0.1.21以上が必要です

## 1. install_macro_pluginでマクロを有効化します
* `setting.yml` に`install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::DaseiCancel` と書きます
* これを記述することで、layer内で呼び出せるようになります

```
install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::DaseiCancel
```

## 2. どのlayerで発動するかを宣言します
* `setting.yml` のlayer内に`macro ProconBypassMan::Plugin::Splatoon2::Macro::DaseiCancel, if_pressed: [:zl]` と書きます
  * `if_pressed` がどのボタンを押したときにこのマクロが発動するかの設定です
      * 惰性キャンセルなのでイカ状態になるためにzlを押します
  * `if_tilted_left_stick` がスティックを倒した時に発動するオプションです

```
layer :up do
  macro ProconBypassMan::Plugin::Splatoon2::Macro::DaseiCancel, if_tilted_left_stick: true, if_pressed: [:zl]
end
```

## 3. 設定を反映させる
* 上記の記述を加えたsetting.ymlを起動中のprocon_bypass_manプロセスで読み込むには、プロセスにその旨を伝える必要があります
    * ラズベリーパイを再起動して、プロセスを立ち上げ直す、でも目的は達成できますが、もっと簡単にsetting.ymlを再読み込みする必要があります
* 書き換えたsetting.ymlを、起動中のprocon_bypass_manプロセスへ即時反映するには、procon_bypass_manプロセスを動かしたまま、別のshellから 以下をを実行してください
    * setting.ymlのシンタックスが正しければ、switchとの接続が継続したままsetting.ymlの内容を読み込んでいるはずです

## 設定例1
```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]
  install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::DaseiCancel

  layer :up do
    macro ProconBypassMan::Plugin::Splatoon2::Macro::DaseiCancel, if_tilted_left_stick: true, if_pressed: [:zl]
  end
```

## 設定例2
* `open_macro` キーワードを使っても同じことが実行可能です。
* この場合は、 `install_macro_plugin` が不要です。

```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]

  layer :up do
    open_macro :dacan, steps: [:pressing_r_for_0_03sec, :pressing_r_and_pressing_zl_for_0_2sec], if_tilted_left_stick: true, if_pressed: [:zl]
  end
```

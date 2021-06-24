# ProconBypassMan
* プロコンを連射機にしたり、キーのリマップをしたり、マクロを実行できるツールです
    * 設定ファイルはrubyスクリプトで記述します
* 特定のタイトルに特化した振る舞いにしたい時は各プラグインを使ってください

## 使うハードウェア
* プロコン
* Switch本体とドック
* Raspberry Pi4
    * 他のシリーズは未確認です
* データ通信が可能なUSBケーブル

## 使うソフトウェア
* 必須
  * ruby-3.0.x

## Usage
* 以下のファイルを用意して`sudo`をつけて実行してください
    * ex) `sudo bin/run.rb`

```ruby
# bundler inline
require 'bundler/inline'

gemfile do
  gem 'procon_bypass_man', github: 'splaspla-hacker/procon_bypass_man', branch: "0.1.2"
end

ProconBypassMan.run(setting_path: "./setting.yml")
```

setting.yml

```yml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
  layer :up do
    flip :zr, if_pressed: :zr
    flip :zl, if_pressed: [:y, :b, :zl]
    flip :down, if_pressed: true
  end
  layer :right do
  end
  layer :left
  layer :down do
    flip :zl, if_pressed: true
    remap :l, to: :zr
  end
```

### プラグインを使った設定例
```ruby
#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  gem 'procon_bypass_man', github: 'splaspla-hacker/procon_bypass_man', branch: "0.1.2"
  gem 'procon_bypass_man-splatoon2', github: 'splaspla-hacker/procon_bypass_man-splatoon2', branch: "0.1.0"
end

ProconBypassMan.run(setting_path: "./setting.yml")
```
setting.yml

```yml
version: 1.0
setting: |-
  fast_return = ProconBypassMan::Splatoon2::Macro::FastReturn
  guruguru = ProconBypassMan::Splatoon2::Mode::Guruguru

  install_macro_plugin fast_return
  install_mode_plugin guruguru

  prefix_keys_for_changing_layer [:zr, :r, :zl, :l]

  layer :up, mode: :manual do
    flip :zr, if_pressed: :zr, force_neutral: :zl
    flip :zl, if_pressed: [:y, :b, :zl]
    flip :down, if_pressed: :down
    macro fast_return.name, if_pressed: [:y, :b, :down]
  end
  layer :right, mode: guruguru.name
  layer :left do
    # no-op
  end
  layer :down do
    flip :zl
  end
```

* 設定ファイルの例
  * https://github.com/jiikko/procon_bypass_man_sample

## Plugins
* https://github.com/splaspla-hacker/procon_bypass_man-splatoon2

## プラグインの作り方
https://github.com/splaspla-hacker/procon_bypass_man-splatoon2 を見てみてください

### モード(mode)
* name, binariesの持つオブジェクトを定義してください
* binariesには、Proconが出力するバイナリに対して16進数化した文字列を配列で定義してください

### マクロ(macro)
* name, stepsの持つメソッドをオブジェクトを定義してください
* stepsには、プロコンで入力ができるキーを配列で定義してください
  * 現在はintervalは設定できません

## FAQ
### ソフトウェアについて
* どうやって動かすの?
    * このツールはRaspberry Pi4をUSBガジェットモードで起動して有線でプロコンとSwitchに接続して使います
* どうやって使うの？
    * ケーブルでそれらを接続した状態で、Raspberry Pi4にsshして本プログラムを起動することで使用します
* ラズベリーパイ4のセットアップ方法は？
    * https://github.com/splaspla-hacker/procon_bypass_man/tree/master/docs/setup_raspi.md
* モード, マクロの違いは？
    * modeはProconの入力をそのまま再現するため機能。レイヤーを切り替えるまで繰り返し続ける
    * マクロは特定のキーを順番に入れていく機能。キーの入力が終わったらマクロは終了する
* レイヤーとは？
    * 自作キーボードみたいな感じでレイヤー毎に設定内容を記述して切り替えれる
* このツールでできることは？
    * キーリマップ, 連射, マクロ, 特定の同じ操作の繰り返し(mode)
        * リマップは1つのキーを別のキーに割り当てます
    * 連射中には特定のキーの入力を無視したり、複数のキーをトリガーに連射することができます
* どうしてsudoが必要なの？
    * 操作するdeviceファイルがrootだから

## TODO
* ログをfluentdへ送信
* 設定ファイルをwebから反映できる
* ケーブルの抜き差しなし再接続(厳しい)
    * 接続確立後、プロセスを強制停止し、接続したままプロセスを再起動すると、USBの経由での接続ができなくなる
        * ケーブルを抜いてからリトライすると改善する
        * ケーブルで繋がっているけどswitchとプロコンがBluetoothで繋がっている状態かつ非充電状態だとバイパスができない、ということがわかった
    * ラズパイとプロコン間でBluetooth接続できれば解決するかもしれない
        * ジャイロの入力を取る方法がまだ発見できていないらしく厳しいことがわかった
            * https://github.com/dekuNukem/Nintendo_Switch_Reverse_Engineering/issues/7
        * それとSwitchOS 12からペアリングの仕様に変更があって類似ツールが動かなくっている
* ラズパイのプロビジョニングを楽にしたい
* レコーディング機能(プロコンの入力をマクロとして登録ができる)
* swtichとの接続完了はIOを見て判断する
* webページから設定ファイルを変更できるようにする(sshしたくない)
    * webサーバのデーモンとPBMはプロセスを分ける(NOTE)
* プロセスを停止するときにtmp/pidを削除する

## 開発系TIPS
### ロギング
```ruby
ProconBypassMan.tap do |pbm|
  pbm.logger = STDOUT
  pbm.logger.level = :debug
end
```

### 設定ファイルのライブリロード
```shell
sudo kill -USR2 `cat tmp/pid`
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

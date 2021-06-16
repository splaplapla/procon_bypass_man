# ProconBypassMan
* プロコンを連射機にするツールです
* 特定のタイトルに特化した振る舞いにしたい時は各プラグインを使ってください(TODO)

## 使うハードウェア
* プロコン
* Switch本体とドック
* Raspberry Pi4

## 使うソフトウェア
* 必須
  * ruby-3.0.x
* オプション
  * fluentd

## Usage
以下のファイルを用意して`sudo ruby hoge.rb`してください

```ruby
# bundler inline
gem 'procon_bypass_man', github: 'splaspla-hacker/procon_bypass_man'
require 'procon_bypass_man'

module Splatoon2TheMode
  # @return [Symbol]
  def self.plugin_name
    :splatoon2_something_mode
  end

  # @return [Array<String>]
  def binaries
    [...]
  end
end

ProconBypassMan.run do
  prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
  install_mode_plugin(Splatoon2TheMode)

  layer :up, mode: :manual do
    flip :zr, if_pushed: :zr, force_neutral: :zl
    flip :zl, if_pushed: [:y, :b, :zl]
    flip :down, if_pushed: true
    macro :fast_return, if_pushed: [:y, :b, :down]
  end
  layer :right do
  end
  layer :left, mode: :splatoon2_something_mode
  layer :down do
    flip :zl, if_pushed: true
  end
end
```

## Plugins
* https://github.com/splaspla-hacker/procon_bypass_man-splatoon2

## プラグインの作り方(TODO)
スケルトンを出力するgeneratorを作るか、普通にgemで作るか

### モード

```
module Splatoon2GuruguruMode
  # @return [Symbol]
  def self.plugin_name
    :guruguru
  end

  # @return [Array<String>]
  def binaries
    [...]
  end
end
```

### マクロ
TODOo

## FAQ
### ソフトウェアについて
* どうやって動かすの?
    * このツールはRaspberry Pi4をUSBガジェットモードで起動して有線でプロコンとSwitchに接続して使います
* ラズベリーパイ4のセットアップ方法は？
    * Raspberry Pi4本体のセットアップがめんどいです。自力で調べてください

### 設定について
* モード, マクロの違いは？
    * modeはProconの入力をそのまま再現するため機能。レイヤーを切り替えるまで繰り返し続ける
    * マクロは特定のキーを順番に入れていく機能。キーの入力が終わったらマクロは終了する

## TODO
* pluginsの仕組み/pluginへ切り出す
* ログをfluentdへ送信
* 設定ファイルをwebから反映できる
* プロセスの再起動なしで設定の再読み込み
* ケーブルの抜き差しなし再接続
* ラズパイのプロビジョニングを楽にしたい
* 設定ファイルのlintを作る
* レコーディング機能(プロコンの入力をマクロとして登録ができる)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/procon_bypass_man. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/procon_bypass_man/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# ProconBypassMan
* プロコンを連射機にしたり、マクロを実行できるツールです
    * 設定ファイルはrubyスクリプトで記述します
* 特定のタイトルに特化した振る舞いにしたい時は各プラグインを使ってください(TODO)

## 使うハードウェア
* プロコン
* Switch本体とドック
* Raspberry Pi4
    * 他のシリーズは未確認です
* データ通信が可能なUSBケーブル

## 使うソフトウェア
* 必須
  * ruby-3.0.x
* オプション
  * fluentd

## Usage
* 以下のファイルを用意して`sudo ruby hoge.rb`してください
* 設定ファイルの例
  * https://github.com/jiikko/procon_bypass_man_sample

```ruby
# bundler inline
gem 'procon_bypass_man', github: 'splaspla-hacker/procon_bypass_man'
require 'procon_bypass_man'

ProconBypassMan.run do
  prefix_keys_for_changing_layer [:zr, :r, :zl, :l]

  layer :up, mode: :manual do
    flip :zr, if_pressed: :zr, force_neutral: :zl
    flip :zl, if_pressed: [:y, :b, :zl]
    flip :down, if_pressed: true
  end
  layer :right do
  end
  layer :left
  layer :down do
    flip :zl, if_pressed: true
  end
end
```

## FAQ
### ソフトウェアについて
* どうやって動かすの?
    * このツールはRaspberry Pi4をUSBガジェットモードで起動して有線でプロコンとSwitchに接続して使います
* ラズベリーパイ4のセットアップ方法は？
    * Raspberry Pi4本体のセットアップがめんどいです。(TODO)
* モード, マクロの違いは？
    * modeはProconの入力をそのまま再現するため機能。レイヤーを切り替えるまで繰り返し続ける
    * マクロは特定のキーを順番に入れていく機能。キーの入力が終わったらマクロは終了する
* レイヤーとは？
    * 自作キーボードみたいな感じでレイヤー毎に設定内容を記述して切り替えれる

## TODO
* ログをfluentdへ送信
* 設定ファイルをwebから反映できる
* プロセスの再起動なしで設定の再読み込み
* ケーブルの抜き差しなし再接続
    * 接続確立後、プロセスを強制停止する、接続したままプロセスを再起動する
    * "81020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" 最後にデッドロックする
    * ケーブルを抜いてからリトライすると改善する
* ラズパイのプロビジョニングを楽にしたい
* 起動時に設定ファイルのlintを行う(サブスレッドが起動してから死ぬとかなしいのでメインスレッドで落としたい)
* レコーディング機能(プロコンの入力をマクロとして登録ができる)
* たまに数秒ハングアップする問題を直す

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/procon_bypass_man. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/procon_bypass_man/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# ProconBypassMan
* プロコンを連射機にするツールです
* 特定のタイトルに特化した振る舞いにしたい時は各プラグインを使ってください(TODO)

## 使うハードウェア
* プロコン
* Switch
* Raspberry Pi4

## Usage
以下のファイルを用意して`sudo ruby hoge.rb`してください

```ruby
# bundler inline
gem 'procon_bypass_man', github: 'splaspla-hacker/procon_bypass_man'

ProconBypassMan.run do
  plugin 'splaspla-hacker/procon_bypass_man-splatoon2'
end
```

## Plugins
* https://github.com/splaspla-hacker/procon_bypass_man-splatoon2

## プラグインの作り方(TODO)
スケルトンを出力するgeneratorを作るか、普通にgemで作るか

```
```

## FAQ
* どうやって動かすの?
    * このツールはRaspberry Pi4をUSBガジェットモードで起動して有線でプロコンを接続して使います
* ラズベリーパイ4のセットアップ方法は？
    * Raspberry Pi4本体のセットアップがめんどいです。自力で調べてください

## TODO
* pluginsの仕組み/pluginへ切り出す
* layerを切り替えれる仕組み
* ログをfluentdへ送信
* モードを切り替え(プロセスの起動なしで、モードのon/offをしたい)
  * webから入力できる
  * 標準入力から受け取るか
  * 特定のキーを入れるとスイッチできるようにする？

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/procon_bypass_man. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/procon_bypass_man/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

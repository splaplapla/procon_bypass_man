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

# no support
# ProconBypassMan.run do
#   flip :down, :zr
#   plugin 'splaspla-hacker/procon_bypass_man-splatoon2' do
#     fast_return
#   end
# end

ProconBypassMan.run do
  prefix_keys_for_changing_layer [:zr, :r, :zl, :l]
  layer :up do
    flip [:down, :zr], if_pushed: true
    flip [:zl], if_pushed: [:y, :b]
    plugin 'splaspla-hacker/procon_bypass_man-splatoon2' do
      fast_return
    end
  end
  layer :right do
  end
  layer :left do
  end
  layer :down do
    flip [:zl]
  end
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
    * このツールはRaspberry Pi4をUSBガジェットモードで起動して有線でプロコンとSwitchに接続して使います
* ラズベリーパイ4のセットアップ方法は？
    * Raspberry Pi4本体のセットアップがめんどいです。自力で調べてください

## TODO
* pluginsの仕組み/pluginへ切り出す
* ログをfluentdへ送信
* 設定ファイルをwebから反映できる

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/procon_bypass_man. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/procon_bypass_man/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

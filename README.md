# ProconBypassMan
* プロコンを連射機にするツールです
* 特定のタイトルに特化した振る舞いにしたい時は各プラグインを使ってください(TODO)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'procon_bypass_man', github: 'splaspla-hacker/procon_bypass_man'
```

And then execute:

    $ bundle install

## Usage
```
ProconBypassMan.run do
  plugin :splatoon2
end
```

## Development
```
sudo bundle install --path vendor/bundle --jobs 1000
sudo bin/run
```

## Plugins
* https://github.com/splaspla-hacker/procon_bypass_man-splatoon2

### Callbacks
```
```

## プラグインの作り方(TODO)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/procon_bypass_man. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/procon_bypass_man/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## TODO
* pluginsの仕組み/pluginへ切り出す
* layerを切り替えれる仕組み
* ログをfluentdへ送信
* モードを切り替え(プロセスの起動なしで、モードのon/offをしたい)
  * webから入力できる
  * 標準入力から受け取るか
  * 特定のキーを入れるとスイッチできるようにする？

# ラズベリーパイのシリアルポート(GPIO)へ書き込んでPBM経由してSwitchへ入力をする方法
* procon_bypass_man: 0.3.7以上が必要です
* GPIOからSwitchへ入力できます。本テキストでは設定方法を記載します

## 1. シリアルポートへ書き込みができるようにラズベリーパイのセットアップする
https://toki-blog.com/pi-serial/ の「汎用シリアルとして使う」 を実施してください

## 2. GPIOへケーブルを挿す
対応しているケーブルをGPIOとPCに接続してください。

## 3. PBMのapp.rbを編集し、シリアルポートから読み出せるようにPBMのapp.rbを編集する
`gemの追加`と`デバイスファイルを指す修正` の2つ必要です。

* 1) シリアルポートから読み出すために追加でgemが必要です。 `app.rb` に `gem "serialport"` を追加してください。

```diff
  gemfile do
    source 'https://rubygems.org'
    git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
    gem 'procon_bypass_man', '0.3.7'
+   gem "serialport"
  end
```

* 2) 以下を参考にして`config.external_input_channels`の行を追加してください。

```diff
ProconBypassMan.configure do |config|
  config.root = File.expand_path(__dir__)
  config.logger = Logger.new("#{ProconBypassMan.root}/app.log", 1, 1024 * 1024 * 1)
  config.logger.level = :debug

  # バイパスするログを全部app.logに流すか
  config.verbose_bypass_log = false

  # webからProconBypassManを操作できるwebサービスと連携します
  # 連携中はエラーログ、パフォーマンスに関するメトリクスを送信します
  # config.api_servers = 'https://pbm-cloud.jiikko.com'

  # エラーが起きたらerror.logに書き込みます
  config.enable_critical_error_logging = true

  # pbm-cloudで使う場合はnever_exitにtrueをセットしてください. trueがセットされている場合、不慮の事故が発生してもプロセスが終了しなくなります
  config.never_exit_accidentally = true

  # 接続に成功したらコントローラーのHOME LEDを光らせるか
  config.enable_home_led_on_connect = true

+ config.external_input_channels = [
+   ProconBypassMan::ExternalInput::Channels::SerialPortChannel.new(device_path: '/dev/serial0', baud_rate: 9600),
+ ]
end
```

以上で設定は完了です。PBMを起動し、連携ツールからGPIOへ書き込んでください。  
書き込みフォーマットについては [ラズベリーパイのシリアルポート(GPIO)に書き込むフォーマットについて](/docs/setting/integration_external_input_serial_port_format.md) を参照してください。

#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require

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

  # シリアル通信やTCP/IP経由で入力するときに設定してください
  # config.external_input_channels = [
  #   ProconBypassMan::ExternalInput::Channels::SerialPortChannel.new(device_path: '/dev/serial0', baud_rate: 9600),
  #   ProconBypassMan::ExternalInput::Channels::TCPIPChannel.new(port: 9000),
  # ]
end

ProconBypassMan.run(setting_path: "/usr/share/pbm/current/setting.yml")

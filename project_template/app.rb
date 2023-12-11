#!/usr/bin/env ruby

require 'bundler/inline'

retry_count_on_git_command_error = 0
begin
  if retry_count_on_git_command_error > 10
    STDOUT.puts "Stopped the procon_bypass_man program because could not download any source codes."
    exit 1
  end

  gemfile do
    source 'https://rubygems.org'
    git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
    gem 'procon_bypass_man', '0.3.11'
    # uncomment if you want to use master branch
    # gem 'procon_bypass_man', github: 'splaplapla/procon_bypass_man', branch: 'master'
    # uncomment if you want to use serial communication feature
    # gem "serialport"
  end
rescue Bundler::Source::Git::GitCommandError => e
  retry_count_on_git_command_error = retry_count_on_git_command_error + 1
  sleep(5) # サービスの起動順によっては、まだoffline状態なので待機する

  # install中に強制終了するとgitの管理ファイルが不正状態になり、次のエラーが起きるので発生したらcache directoryを削除する
  #"Git error: command `git fetch --force --quiet --tags https://github.com/splaplapla/procon_bypass_man refs/heads/\\*:refs/heads/\\*` in directory /home/pi/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/cache/bundler/git/procon_bypass_man-ae4c9016d76b667658c8ba66f3bbd2eebf2656af has failed.\n\nIf this error persists you could try removing the cache directory '/home/pi/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/cache/bundler/git/procon_bypass_man-ae4c9016d76b667658c8ba66f3bbd2eebf2656af'"
  if /try removing the cache directory '([^']+)'/ =~ e.message && $1&.start_with?('/home/pi/.rbenv')
    require 'fileutils'
    FileUtils.rm_rf($1)
    STDOUT.puts "Deleted #{$1}"
  end

  retry
end

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

#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
  gem 'procon_bypass_man', '0.1.20.2'
end

ProconBypassMan.configure do |config|
  config.root = File.expand_path(__dir__)
  config.logger = Logger.new("#{ProconBypassMan.root}/app.log", 5, 1024 * 1024 * 10)
  config.logger.level = :debug

  # バイパスするログを全部app.logに流すか
  # config.verbose_bypass_log = true

  # webからProconBypassManを操作できるwebサービス
  # config.api_servers = ['https://pbm-cloud.herokuapp.com']

  config.enable_critical_error_logging = true

  # pbm-cloudで使う場合はnever_exitにtrueをセットしてください. trueがセットされている場合、不慮の事故が発生してもプロセスが終了しなくなります
  config.never_exit_accidentally = true

  # 操作が高頻度で固まるときは、 gadget_to_procon_interval の数値は大きくしてください
  config.bypass_mode = { mode: :normal, gadget_to_procon_interval: 5 }
end

ProconBypassMan.run(setting_path: "/usr/share/pbm/current/setting.yml")

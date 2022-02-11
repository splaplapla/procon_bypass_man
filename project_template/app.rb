#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
  gem 'procon_bypass_man', '0.1.19.1'
end

ProconBypassMan.configure do |config|
  config.root = File.expand_path(__dir__)
  config.logger = Logger.new("#{ProconBypassMan.root}/app.log", 5, 1024 * 1024 * 10)
  config.logger.level = :debug
  # webからProconBypassManを操作できるwebサービス
  # config.api_servers = ['https://pbm-cloud.herokuapp.com']
  config.enable_critical_error_logging = true
  # pbm-cloudで使う場合はnever_exitにtrueをセットしてください. trueがセットされている場合、一度起動するとデバイスとの接続が切れてもプロセスが停止しなくなります
  config.never_exit = true
end

ProconBypassMan.run(setting_path: "/usr/share/pbm/current/setting.yml")

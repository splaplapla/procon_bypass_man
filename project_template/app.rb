#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
  gem 'procon_bypass_man', '0.1.12'
  gem 'procon_bypass_man-splatoon2', github: 'splaplapla/procon_bypass_man-splatoon2', tag: "0.1.1"
end

ProconBypassMan.configure do |config|
  config.root = File.expand_path(__dir__)
  config.logger = Logger.new("#{ProconBypassMan.root}/app.log", 5, 1024 * 1024 * 10)
  config.logger.level = :debug
  # config.api_servers = ['https://...']
  config.enable_critical_error_logging = true
end

ProconBypassMan.run(setting_path: "/usr/share/pbm/current/setting.yml")

#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
  gem 'procon_bypass_man', '0.1.8'
  gem 'procon_bypass_man-splatoon2', github: 'splaplapla/procon_bypass_man-splatoon2', tag: "0.1.1"
end

ProconBypassMan.tap do |pbm|
  pbm.root = File.expand_path(__dir__)
  pbm.logger = Logger.new("#{ProconBypassMan.root}/app.log", 5, 1024 * 1024 * 10)
  pbm.logger.level = :debug
end

ProconBypassMan.run(setting_path: "./setting.yml")

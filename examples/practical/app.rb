#!/usr/bin/env ruby

# sudo ln -s /home/pi/src/procon_bypass_man/examples/practical/setting.yml /home/pi/src/procon_bypass_man/setting.yml
# cd src/procon_bypass_man
# sudo ruby examples/practical/app.rb

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'procon_bypass_man', github: 'splaplapla/procon_bypass_man', branch: "edge"
  gem 'procon_bypass_man-splatoon2', github: 'splaplapla/procon_bypass_man-splatoon2', branch: "0.1.0"
end

ProconBypassMan.tap do |pbm|
  pbm.logger = Logger.new("#{ProconBypassMan.root}/app.log", 5, 1024 * 1024 * 10) # 5世代まで残して, 10MBでローテーション
  pbm.logger.level = :debug
  pbm.root = File.expand_path(__dir__)
end

ProconBypassMan.run(setting_path: "./setting.yml")

#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'procon_bypass_man', github: 'splaspla-hacker/procon_bypass_man', branch: "edge"
  gem 'procon_bypass_man-splatoon2', github: 'splaspla-hacker/procon_bypass_man-splatoon2', branch: "0.1.0"
end

ProconBypassMan.tap do |pbm|
  pbm.logger = "./app.log"
  pbm.logger.level = :debug
end

ProconBypassMan.run(setting_path: "./setting.yml")

#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
  gem 'procon_bypass_man-web', '0.1.2'
end

ProconBypassMan::Web.configure do |config|
  config.root = File.expand_path(__dir__)
  config.logger = Logger.new("#{ProconBypassMan::Web.root}/web.log", 1, 1024 * 1024 * 10)
end

ProconBypassMan::Web::Server.start

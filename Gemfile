# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in procon_bypass_man.gemspec
gemspec

gem "pry"
gem "rake"
gem "rspec"
gem "rubocop", require: false
gem "serialport" # シリアル通信をする時に必要。通常はいらない
gem "sinatra", require: false
gem "solargraph", "0.50.0", require: false
gem "stackprof", require: false
gem "timecop"
gem "webrick", require: false
gem "nokogiri", "1.15.5", require: false

if Gem::Version.new(RUBY_VERSION) > Gem::Version.new("2.6.0")
  gem 'rbs', require: false
  gem "steep", require: false
  gem 'typeprof', require: false
end

# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in procon_bypass_man.gemspec
gemspec

gem "rake"
gem "rspec"
gem "pry"
gem "timecop"
gem "rubocop", require: false
gem "sinatra", require: false
gem "webrick", require: false
gem "stackprof", require: false
gem "benchmark-ips", require: false

if Gem::Version.new(RUBY_VERSION) > Gem::Version.new("2.6.0")
  gem 'typeprof', require: false
  gem 'rbs', require: false
  gem "steep", require: false
end

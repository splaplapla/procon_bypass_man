# ProconBypassMan
* プロコンを連射機にするベースのライブラリです
* 連射機能は各プラグインを使ってください
* plugins
    * https://github.com/splaspla-hacker/procon_bypass_man-splatoon2

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'procon_bypass_man', github: 'splaspla-hacker/procon_bypass_man'
```

And then execute:

    $ bundle install

## Usage
```
ProconBypassMan.run do
  plugin :splatoon2
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Callbacks
```
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/procon_bypass_man. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/procon_bypass_man/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

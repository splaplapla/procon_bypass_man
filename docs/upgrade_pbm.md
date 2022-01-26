# procon_bypass_man のアップグレード方法
* rbファイル内にある `gem 'procon_bypass_man', ` の後ろの番号を変更することで、procon_bypass_manのバージョンを変更できます
  * 最新バージョンは https://rubygems.org/gems/procon_bypass_man を参照してください
* 変更後は、プログラムを実行し直してください。プログラムを起動中であればraspberry piを再起動後にプログラムを起動してください
* バージョンを変更後、エラーになる場合はサポートするので、discordやissueに報告をお願いします

```ruby
#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
  gem 'procon_bypass_man', '0.1.16.1'
end

ProconBypassMan.configure do |config|
  config.root = File.expand_path(__dir__)
  config.logger = Logger.new("#{ProconBypassMan.root}/app.log", 5, 1024 * 1024 * 10)
  config.logger.level = :debug
  # config.api_servers = ['https://...']
  config.enable_critical_error_logging = true
end

ProconBypassMan.run(setting_path: "/usr/share/pbm/current/setting.yml")
```

```diff
-  gem 'procon_bypass_man', '0.1.16.1'
+  gem 'procon_bypass_man', '0.1.17'
```

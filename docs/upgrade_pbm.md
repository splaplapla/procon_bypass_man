# procon_bypass_man のアップグレード方法
* pbm-cloudを使う方法、pbmenvを使う方法、pbmenvを使わない方法があります

## pbm-cloudを使う方法
* https://pbm-cloud.jiikko.com からデバイス詳細画面を開いてください
* `デバイスの設定` => `PBMのバージョンアップ`を選択して、表示されるモーダルからインストールしたいバージョンを選択し、 `このバージョンでバージョンアップする` をクリックしてください
  * クリックするとRaspberry Piが再起動するのでしばらく待ってください
  * 設定ファイルが初期状態に戻っているので適宜復元してください
* デバイス詳細画面からバージョンが上がっていることを確認してください

## pbmenvを使う方法
* sshをして、以下の3行を実行してください

```
sudo gem i pbmenv
sudo pbmenv install latest
sudo pbmenv use latest
```

* `sudo pbmenv use latest` を実行すると、 `/usr/share/pbm/current/` に新しいバージョンのprocon_bypass_manを配備します
* `/usr/share/pbm/current/setting.yml` が初期状態になっているので適宜変更してください
  * 前バージョンのsetting.ymlは消していないので残っています
* 変更後は、プログラムを起動し直してください

## pbmenvを使わない方法
* rbファイル内にある `gem 'procon_bypass_man', ` の後ろの番号を変更することで、procon_bypass_manのバージョンを変更できます
  * 最新バージョンは https://rubygems.org/gems/procon_bypass_man を参照してください
* 変更後は、プログラムを起動し直してください
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

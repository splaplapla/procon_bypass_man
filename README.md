# ProconBypassMan
[![Ruby](https://github.com/splaplapla/procon_bypass_man/actions/workflows/ruby.yml/badge.svg?branch=master)](https://github.com/splaplapla/procon_bypass_man/actions/workflows/ruby.yml)

* Switchに繋いだプロコンを連射機にしたり、キーのリマップをしたり、マクロを実行できるツールです
    * 設定ファイルはrubyスクリプトで記述します
* 特定のタイトルに特化した振る舞いにしたい時は各プラグインを使ってください

![image](https://user-images.githubusercontent.com/1664497/123414210-942f6980-d5ee-11eb-8192-955bd9e37e0b.png)

```
@startuml
ProController --> (PBM): ZR押しっぱなし
Switch <-- (PBM): ZR連打
@enduml
```

## 使うハードウェア
* プロコン
* Switch本体とドック
* Raspberry Pi4 Model B/4GB(Raspberry Pi OS (32-bit))
    * 他のシリーズは未確認です
        * zeroは非対応
* データ通信が可能なUSBケーブル

## 使うソフトウェア
* ruby-3.0.x

## Usage
* USBガジェットモードで起動するRaspberry Pi4を用意する
  * https://github.com/splaplapla/procon_bypass_man/blob/master/docs/setup_raspi.md
* Raspberry Pi4 でprocon_bypass_manを実行するための準備
  * rubyのインストール
    * sudo apt-get install rbenv
    * git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    * rbenv install 3.0.1
  * sudo gem install pbmenv
  * sudo [pbmenv](https://github.com/splaplapla/pbmenv) install latest
* Raspberry Pi4 でprocon_bypass_manを実行する
  * cd /usr/share/pbm/current
  * sudo /home/pi/.rbenv/versions/3.0.1/bin/ruby app.rb
  * 動いたのを確認したらserviceとして登録にするなどしてください
    * [serviceとして登録する方法](https://github.com/splaplapla/procon_bypass_man/tree/master/project_template#systemd%E3%82%92%E4%BD%BF%E3%81%A3%E3%81%A6%E3%82%B5%E3%83%BC%E3%83%93%E3%82%B9%E3%81%AB%E7%99%BB%E9%8C%B2%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)

## Plugins
* https://github.com/splaplapla/procon_bypass_man-splatoon2

## 関連ソフトウェア
* サーバソフトウェア(WIP)
  * https://github.com/splaplapla/procon_bypass_man_cloud
  * このサーバからOS自体の再起動、設定ファイルの変更、PBMのバージョンアップができます
  * 自分でホストティングしてください
* pbmenv
  * バージョンマネージャー

## FAQ
* どうやって動かすの?
    * このツールはRaspberry Pi4をUSBガジェットモードで起動して有線でプロコンとSwitchに接続して使います
* どうやって使うの？
    * ケーブルでそれらを接続した状態で、Raspberry Pi4にsshして本プログラムを起動することで使用します
* ラズベリーパイ4のセットアップ方法は？
    * https://github.com/splaplapla/procon_bypass_man/tree/master/docs/setup_raspi.md
* モード, マクロの違いは？
    * modeはProconの入力をそのまま再現するため機能。レイヤーを切り替えるまで繰り返し続ける
    * マクロは特定のキーを順番に入れていく機能。キーの入力が終わったらマクロは終了する
* レイヤーとは？
    * 自作キーボードみたいな感じでレイヤー毎に設定内容を記述して切り替えれる
* このツールでできることは？
    * キーリマップ, 連射, マクロ, 特定の同じ操作の繰り返し(mode)
        * リマップは1つのキーを別のキーに割り当てます
    * 連射中には特定のキーの入力を無視したり、複数のキーをトリガーに連射することができます
* どうしてsudoが必要なの？
    * 操作するdeviceファイルの所有者がrootだから
* 市販されているサードパーティ製連射機との違いは？
    * サードパーティ製のコントローラーは、設定方法や形状が特殊で買い換えるたびに学習・設定コストが発生します。本ツールを使えば、設定内容はテキストで管理することができ、使い慣れたプロコンで同等のことができます。

## TODO
* レコーディング機能(プロコンの入力をマクロとして登録ができる)
* マクロにdelayを入れれるようにする

## 開発系
### プロコンとの接続を維持したまま、現在の設定ファイルをPBMに反映する
```shell
sudo kill -USR2 `cat ./pbm_pid`
```

### 起動ログをサーバに送信する
* `ProconBypassMan.api_servers = "http://.."` を設定すると、 `POST /api/events` に対して起動ログなどを送信するようになります

### 開発環境でログの送信を確認する方法
* `bundle exec bin/dev_api_server.rb`
* `API_SERVER=http://localhost:4567 INTERNAL_API_SERVER=http://localhost:4567 bin/console`
  * `message = ProconBypassMan::BootMessage.new; ProconBypassMan::ReportBootJob.perform(body: message.to_hash)`

### リリース手順
* project_template/web.rb, project_template/app.rb, lib/procon_bypass_man/version.rb のバージョンをあげる
* CHANGELOG.md に日付を書く
* be rake release

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Links
* https://discord.gg/bEcRNKf4ep

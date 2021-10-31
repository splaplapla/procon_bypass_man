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
* Raspberry Pi4で https://github.com/jiikko/procon_bypass_man_sample をclone して実行ファイルを動かす
  * 実行ファイルと設定ファイルについては https://github.com/splaplapla/procon_bypass_man/wiki に詳細を書いていますが、まず動かすためにはcloneしたほうが早いです

## Plugins
* https://github.com/splaplapla/procon_bypass_man-splatoon2

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

## TODO
* レコーディング機能(プロコンの入力をマクロとして登録ができる)
* マクロにdelayを入れれるようにする
* 設定ファイル マクロの引数に、ボタンを取れるようにする

## 開発系
* pbmenvで生成するapp.rbに開発用ブランチを参照してください

### プロコンとの接続を維持したまま、現在の設定ファイルをPBMに反映する
```shell
sudo kill -USR2 `cat ./pbm_pid`
```

### 起動ログをサーバに送信する
* `ProconBypassMan.api_server = "http://.."` を設定すると、 `POST /api/reports` に対して起動ログを送信するようになります

### 開発環境でログの送信を確認する方法
* `bundle exec bin/dev_api_server.rb`
* `bin/console`
  * `ProconBypassMan.api_server = "http://localhost:4567"`
  * `message = ProconBypassMan::BootMessage.new; ProconBypassMan::Reporter.report(body: message.to_hash)"`

### リリース手順
* project_template/web.rb, project_template/app.rb, lib/procon_bypass_man/version.rb のバージョンをあげる
* be rake release

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

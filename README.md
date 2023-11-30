# ProconBypassMan
<img src="https://user-images.githubusercontent.com/1664497/151661582-3a1e8ce9-6c38-4754-8075-7a4453b3109a.jpg" width="500px">

[![Ruby](https://github.com/splaplapla/procon_bypass_man/actions/workflows/ruby.yml/badge.svg?branch=master)](https://github.com/splaplapla/procon_bypass_man/actions/workflows/ruby.yml)

* Nintendo Switch Proコントローラーを連射機などにするRaspberry Pi上で動かすコンバータです
* ドキュメントは [getting_started.md](docs/getting_started.md) にまとめています
* https://pbm-cloud.jiikko.com を使うと、webだけで運用が可能です

<img width="880" alt="スクリーンショット 2022-04-02 9 10 38" src="https://user-images.githubusercontent.com/1664497/161356057-71e4bc2a-0217-4434-9bf1-0002b9fb261a.png">

https://user-images.githubusercontent.com/1664497/171327108-f12f56a5-fc36-48da-95a5-65e976553a20.mov

## 必要なハードウェア
* Nintendo Switch Proコントローラー
* Switch本体とドック
* Raspberry Pi4 (Raspberry Pi OS)
    * 他のシリーズは未確認です
* データ通信が可能なUSBケーブル

## 必要なソフトウェア
* ruby 2.5 以上

## プラグイン
* https://github.com/splaplapla/procon_bypass_man-splatoon2
* [スプラトゥーン3](docs/setting/splatoon3_recommended_setting.md)

## FAQ
* どうやって動かすの?
    * このツールはRaspberry Pi4をUSBガジェットモードで起動して有線でプロコンとSwitchに接続して使います
* どうやって使うの？
    * ケーブルでそれらを接続した状態で、Raspberry Pi4にsshして本プログラムを起動することで使用します
* ラズベリーパイ4のセットアップ方法は？
    * https://github.com/splaplapla/procon_bypass_man/tree/master/docs/setup_raspi.md
* レイヤーとは？
    * 自作キーボードみたいな感じでレイヤー毎に設定内容を記述して切り替えれます
    * レイヤーは4つあって、up, down, left, rightです。十字キーに対応しています
* レイヤーを切り替える方法は？
    * 設定ファイルに記述している `prefix_keys_for_changing_layer`の後ろにあるキーを同時押しながら、十字キーのどれかを押すことで任意のレイヤーに切り替わります
* このツールでできることは？
    * キーリマップ, 連射, マクロ, 外部ツールからの入力
        * リマップは1つのキーを別のキーに割り当てます
    * 連射中には特定のキーの入力を無視したり、複数のキーをトリガーに連射することができます
    * スプラ2, 3の自動ドット打ち
        * https://zenn.dev/jiikko/articles/fcec13200487d5
    * オートトリガー
        * https://zenn.dev/jiikko/articles/e794f89afe8896
* どうしてsudoが必要なの？
    * 操作するdeviceファイルの所有者がrootだからです
* 市販されているサードパーティ製連射機との違いは？
    * サードパーティ製のコントローラーは、設定方法や形状が特殊で買い換えるたびに学習・設定コストが発生します。本ツールを使えば、設定内容はテキストで管理することができ、使い慣れたプロコンで同等のことができます
* sshなしで運用は可能ですか？
    * https://pbm-cloud.jiikko.com を使えば、sshを使わずに運用が可能です

## 仕様・制約
* 日を跨ぐ24時ちょうどになった瞬間はLinuxのcronが起動などがするようで、この時間は数秒間バイパスが激しく遅延します
  * ログファイルのローテションが少なくとも走るはずなので、不要なデーモンを停止するなどで影響を小さくすることはできると思いますが、完全に抑制することは難しいと思います
* コントローラーから読み取ってSwitchに書き込む時間は、少なくとも0.02秒はかかります
  * 遅延は動かしているRaspberry Piの負荷に依存します

<!--
## TODO
* レコーディング機能(プロコンの入力をマクロとして登録ができる)
* ドキュメントを書く(doing)

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
* project_template/app.rb.erb, lib/procon_bypass_man/version.rb のバージョンをあげる
* CHANGELOG.md に日付を書く
* be rake release
* githubのreleaseを作成する
-->

## 開発を支援してくれる人を募集しています
* https://jiikko.fanbox.cc/
* procon_bypassの運営・開発・サーバー費用に充てさせていただきます。また、問い合わせに優先して対応します。

## Links
* https://discord.gg/GjaywxVZHY
  * 質問などご意見をdiscordでも受け付けています

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# ProconBypassMan
* プロコンを連射機にしたり、キーのリマップをしたり、マクロを実行できるツールです
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
* Raspberry Pi4(Raspberry Pi OS (32-bit))
    * 他のシリーズは未確認です
* データ通信が可能なUSBケーブル

## 使うソフトウェア
* 必須
  * ruby-3.0.x

## Usage
* USBガジェットモードで起動するRaspberry Pi4を用意する
* https://github.com/jiikko/procon_bypass_man_sample をRaspberry Pi4でclone して実行ファイルを動かす
  * 実行ファイルと設定ファイルについては https://github.com/splaspla-hacker/procon_bypass_man/wiki に詳細を書いていますが、まず動かすためにcloneしたほうが早いです

## Plugins
* https://github.com/splaspla-hacker/procon_bypass_man-splatoon2

## FAQ
* どうやって動かすの?
    * このツールはRaspberry Pi4をUSBガジェットモードで起動して有線でプロコンとSwitchに接続して使います
* どうやって使うの？
    * ケーブルでそれらを接続した状態で、Raspberry Pi4にsshして本プログラムを起動することで使用します
* ラズベリーパイ4のセットアップ方法は？
    * https://github.com/splaspla-hacker/procon_bypass_man/tree/master/docs/setup_raspi.md
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
* 設定ファイルをwebから反映できる
* ラズパイのプロビジョニングを楽にしたい
* レコーディング機能(プロコンの入力をマクロとして登録ができる)
* swtichとの接続完了はIOを見て判断する
* webページから設定ファイルを変更できるようにする(sshしたくない)
    * webサーバのデーモンとPBMはプロセスを分ける(NOTE)
* プロセスを停止するときにtmp/pidを削除する

## 開発系TIPS
### ロギング
```ruby
ProconBypassMan.tap do |pbm|
  pbm.logger = STDOUT
  pbm.logger.level = :debug
end
```

### 設定ファイルのライブリロード
```shell
sudo kill -USR2 `cat tmp/pid`
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# GETTING STARTED 
## 目次
* [はじめに](#はじめに)
    * [procon_bypass_manで解決したいこと](#procon_bypass_manで解決したいこと)
    * [procon_bypass_manでできること](#procon_bypass_manでできること)
* [セットアップ](#セットアップ)
  * [ラズベリーパイのセットアップ](#ラズベリーパイのセットアップ)
  * [procon_bypass_manのインストール](#procon_bypass_manのインストール)
      * [pbmenvを使う方法](#pbmenvを使う方法)
      * [pbmenvを使わない方法](#pbmenvを使わない方法)
* [普段使いをするためのセットアップ](#普段使いをするためのセットアップ)
* レイヤー
* モード
* マクロ
* [左スティックの感度調整](#左スティックの感度調整)
* 設定ファイルの書き方
* プラグインの書き方
* [設定ファイルの書き方がわからない、エラーが起きるとき](#設定ファイルの書き方がわからない、エラーが起きるとき)
* [procon_bypass_manのアップグレード方法](#procon_bypass_manのアップグレード方法)
* [procon_bypass_man_cloudについて](#procon_bypass_man_cloudについて)

## はじめに
### procon_bypass_manで解決したいこと

通常、ボタン連射をするには、市販されているサードパーティー製のコントローラーを使う必要があるのですが、ボタンの押した感覚や各種設定方法は各社の独自仕様であるため、それらを手に馴染ませるのがとても大変です。  
特に「説明書を熟読してコントローラーの設定方法を覚えること、設定されている状態を思い出す」がつらい。

このツールを使うことで、使い慣れたコントローラーを使ってボタン連射ができます。また、設定内容はテキストで管理しているため一目瞭然です。

### procon_bypass_manでできること

* 設定内容を即時に入れ替え（レイヤー管理)
* 連射
  * 連射中は特定のキーの入力を無視したり、複数のキーをトリガーに連射することもできます
* マクロ
  * [活用例](/docs/setting/splatoon2_macro_sokuwari_bubble.md)
* 特定の同じ操作の繰り返し(モード)
* 左スティックの感度調整
  * [設定方法](/docs/setting/left-analogstick-cap.md)
* WEBから設定状態の閲覧・反映
* ボタンリマップ

## セットアップ
### ラズベリーパイのセットアップ

* 後で書きます

### procon_bypass_manのインストール

pbmenvを使うと https://pbm-cloud.herokuapp.com と連携ができるのでおすすめですが、pbmenvを使わなくてもprocon_bypass_manをインストールすることは可能です。

#### pbmenvを使う方法

https://github.com/splaplapla/pbmenv  
pbmenvはprocon_bypass_manのバージョンマネジャーです。procon_bypass_manはバージョンアップによって起動スクリプトに変更が入ることがあって、バージョンアップするときはpbmenvを使うとエラーが起きることなくインストールができるようになります。また、pbm-cloudと連携してすべての機能を使うには、pbmenvの利用が必須になります。

```
gem install pbmenv
sudo pbmenv install latest
cd /usr/share/pbm/current
sudo /home/pi/.rbenv/versions/3.0.1/bin/ruby app.rb
```

#### pbmenvを使わない方法

https://github.com/jiikko/procon_bypass_man_sample にある app.rb と setting.yml を Raspberry Pi にダウンロードし、ruby 3.0.1 をインストールすれば起動することができます。

```
rbenv install 3.0.1
sudo /home/pi/.rbenv/versions/3.0.1/bin/ruby app.rb
```

## 普段使いをするためのセットアップ

procon_bypass_manを起動するだけでプロコンと接続ができるようになったら、Raspberry Piを起動したときにprocon_bypass_manも自動起動するように設定しましょう。  
これを設定すると、Switch本体の電源ボタンを押すだけで使えるようになります。(実際には、Raspberry Piが起動して、procon_bypass_manが動き始めるまでに30秒くらいかかります。)

自動起動方法は、pbmenvを使っているなら以下の2行をshellで実行すれば完了です。

```
sudo systemctl link /usr/share/pbm/current/systemd_units/pbm.service
sudo systemctl enable pbm.service
```

pbmenvを使っていない場合は、 https://github.com/splaplapla/procon_bypass_man/blob/master/project_template/systemd_units/pbm.service をダウンロードして、 `systemctl link` をしてください。

ゲームをやめたくなったらSwitchはそのままスリープに入って問題ないです。このときにRaspberry Piも一緒に電源が切れてしまいますが故障することはありません。

## レイヤー
* 後で書きます

## モード
* 後で書きます

## マクロ
* 後で書きます

## 左スティックの感度調整
[左スティックの感度調整](/docs/setting/left-analogstick-cap.md)

## 設定ファイルの書き方
* 後で書きます

## プラグインの書き方
* 後で書きます

## 設定ファイルの書き方がわからない、エラーが起きるとき

設定ファイル(setting.yaml)は、内部がRubyスクリプトになっているので構文エラーが起きることがあります。  
discordで質問してみてください。

## procon_bypass_manのアップグレード方法
[procon_bypass_manのアップグレード方法](/docs/upgrade_pbm.md)

## procon_bypass_man_cloudについて
https://pbm-cloud.herokuapp.com/  
procon_bypass_man_cloudの運用をWEBで完結できるようになる無料のWEBサービスです。  
  
procon_bypass_man_cloudとの接続が完了後、Raspberry Piを起動時にprocon_bypass_man_cloudが自動で立ち上がるように設定すれば、Raspberry Piへのログインが不要で設定ファイルの変更やprocon_bypass_man_cloudのアップグレードができます。  
セットアップ方法などでわからないことがあればdiscordで質問してみてください。  
セットアップ方法は https://pbm-cloud.herokuapp.com/faq に書いています。

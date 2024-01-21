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
* [RaspberryPiの給電について](#RaspberryPiの給電について)
* [普段使いをするためのセットアップ](#普段使いをするためのセットアップ)
* [レイヤー](#レイヤー)
* [マクロ](#マクロ)
* [左スティックの感度調整](#左スティックの感度調整)
* [設定ファイルの書き方](#設定ファイルの書き方)
* プラグインの書き方
* [設定ファイルの書き方がわからない、エラーが起きるとき](#設定ファイルの書き方がわからない、エラーが起きるとき)
* [procon_bypass_manのアップグレード方法](#procon_bypass_manのアップグレード方法)
* [procon_bypass_man_cloudについて](#procon_bypass_man_cloudについて)
* [シリアルポート連携](#シリアルポート連携)
* [TCPIP連携](#TCPIP連携)
* [最適化について](#最適化について)

## はじめに
### procon_bypass_manで解決したいこと

サードパーティー製のコントローラーは頑丈で使いやすいですか？  
  
通常、ボタンの連射をするには、サードパーティー製のコントローラーを使う必要があるのですが、ボタンの押した感覚や各種設定方法は各社の独自仕様であるため、それらを手に馴染ませるのがとても大変です。  
特に「説明書を熟読して、コントローラーの設定方法を理解し適用すること、時間が空いてから設定されている状態を思い出す」がつらいと思っています。  
また、サードパーティー製のコントローラーは非常に壊れやすく、同じ製品が再び購入できるとは限りません。
  
本ツールを使うと、使い慣れた純正コントローラーを使って、サードパーティー製のコントローラー以上のことができます。設定内容はテキストで管理しているため一目瞭然です。設定内容のコピーも容易です。

### procon_bypass_manでできること

* 設定内容を即時に入れ替え（レイヤー管理)
* 連射
  * 連射中は特定のキーの入力を無視したり、複数のキーをトリガーに連射することもできます
* マクロ
  * [活用例](/docs/setting/splatoon2_macro_sokuwari_bubble.md)
* 左スティックの感度調整
  * [設定方法](/docs/setting/left-analogstick-cap.md)
* WEBから設定状態の閲覧・反映
* ボタンリマップ
<!--
* 入力表示
  * https://github.com/splaplapla/switch-procon-input-viewer
-->

## セットアップ
### ラズベリーパイのセットアップ

* 後で書きます

### procon_bypass_manのインストール

pbmenvを使うと https://pbm-cloud.jiikko.com と連携ができるのでおすすめですが、pbmenvを使わなくてもprocon_bypass_manをインストールすることは可能です。  
次の4つからインストール方法を1つ選んでください。

* pbmenvを使う方法
  * systemにインストールされているrubyを使う場合(初心者におすすめ)
  * rbenvでインストールしたrubyを使う場合
* pbmenvを使わない方法
  * systemにインストールされているrubyを使う場合(初心者におすすめ)
  * rbenvでインストールしたrubyを使う場合

ちなみに、rbenvを使った方がラグは少ないような気がしますが、明確な体験の違いはそこまでないように思います。

#### 1) pbmenvを使う方法

https://github.com/splaplapla/pbmenv  
pbmenvはprocon_bypass_manのバージョンマネジャーです。  
procon_bypass_manはバージョンアップによって起動スクリプトに変更が入ることがあって、バージョンアップするときはpbmenvを使うとエラーが起きることなくインストールができるようになります。また、pbm-cloudと連携してすべての機能を使うには、pbmenvの利用が必須になります。

##### 1-1) systemにインストールされているrubyを使う場合(初心者におすすめ)

```bash
sudo apt-get install ruby ruby-dev
sudo gem i bundler pbmenv
sudo pbmenv install latest --use
cd /usr/share/pbm/current
sudo ruby app.rb
```

##### 1-2) rbenvでインストールしたrubyを使う場合
rbenvはrubyのパッケージマネージャーです。  

```bash
rbenv install 3.0.1
sudo gem install pbmenv
sudo pbmenv install latest --use
cd /usr/share/pbm/current
sudo /home/pi/.rbenv/versions/3.0.1/bin/ruby app.rb
```

#### 2) pbmenvを使わない方法
https://github.com/jiikko/procon_bypass_man_sample にある app.rb と setting.yml を Raspberry Pi にダウンロードすれば、起動することができます。  

##### 2-1) systemにインストールされているrubyを使う場合(初心者におすすめ)

```bash
sudo apt-get install ruby ruby-dev wget
wget https://raw.githubusercontent.com/jiikko/procon_bypass_man_sample/master/app.rb
wget https://raw.githubusercontent.com/jiikko/procon_bypass_man_sample/master/setting.yml
sudo gem i bundler
sudo ruby app.rb
```

##### 2-2) rbenvでインストールしたrubyを使う場合
rbenvはrubyのパッケージマネージャーです。  

```bash
rbenv install 3.0.1
sudo apt-get install wget
wget https://raw.githubusercontent.com/jiikko/procon_bypass_man_sample/master/app.rb
wget https://raw.githubusercontent.com/jiikko/procon_bypass_man_sample/master/setting.yml
sudo /home/pi/.rbenv/versions/3.0.1/bin/ruby app.rb
```

## RaspberryPiの給電について
Raspberry Piの状態によっては、Switchと接続しているときに、Raspberry Piが電力不足になるようで動作が不安定になることがあります。  
不安定になるようであれば、Switch以外からも給電してみてください。詳細には言及しませんが、主な給電方法には、以下があります。

* GPIO端子
* PoE

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
レイヤーごとにボタンの設定をすることができ、用途に応じてレイヤーを切り替えることで、違う設定を即座に適用できるという機能です。  
レイヤーは、up, down, left, rightの4つあります。 設定ファイルの書いている `prefix_keys_for_changing_layer` を押しながら、十字キーのup, down, left, rightのどれかを押すと、レイヤーを変更することができます。  
  
設定ファイルでのレイヤー毎の定義方法は、 `layer` ブロックで囲って定義します。  
以下の例は、upレイヤーとleftレイヤーだけに設定が書かれています。ゲーム進行状況によってレイヤーを切り替えてください。  
procon_bypass_manを起動した直後に有効になっているレイヤーは、 up です。

```ruby
layer :up do
  flip :a, if_pressed: [:a]
end

layer :right do
end

layer :left do
  flip :zr, if_pressed: :zr, force_neutral: :zl
end

layer :down do
end
```

## マクロ

決まった入力を繰り返し実行できる機能を「マクロ」と呼んでいます。  
マクロを使うことで、スプラトゥーンであれば、バブル即割の操作や、試合中の味方へのスーパージャンプもマクロ経由で入力できます。  
  
設定ファイルに記述するマクロは文字列で定義します。 
マクロを設定ファイルに定義するには、「プラグイン」か設定ファイルへ直接を記述する「open_macro」のどちらかで行えます。  
  
「プラグイン」を使用する場合は、マクロの詳細を記述する必要がなく、PBMのバージョンアップとともに改善が入る可能性があります。  
open_macroは、マクロの詳細を設定ファイルに直書きするため、設定ファイルが複雑になる可能性がある反面、柔軟なマクロを定義することができます。  
プラグインで提供されているマクロがあれば、それを使うことをお勧めします。  
プラグインの詳細な設定方法については、 [バブル即割マクロの設定方法](/docs/setting/splatoon2_macro_sokuwari_bubble.md) を参考にしてください。  
  
次はマクロの入力に使えるコマンド（ステップ）の紹介をします。  
マクロに使えるボタンは以下の通りです。  

```
y, x, b, a, sl, sr, r, zr, minus, plus, thumbr, thumbl, home, cap, down, up, right, left, l, zl
```

<!--
マクロの形式には、1ボタンずつ入力する「バージョン1」と時間指定のできる「バージョン2」があります。  
バージョン1は、 `[:x, :y, :up]` と記述すると、x, y, 十字キーの上ボタンを順番に入力します。バージョン1では実行時間を指定することはできません。  
-->
  
マクロは、複数のボタンを同時に「連打」「押しっぱなし」または「待機」ができます。  

連打はtoggleで、押しっぱなしはpressing, 無操作は、waitというキーワードを使います。  
複数のボタンを同時押しの場合は、andで繋ぎます。Xボタンを押しっぱなしにして、ZRボタンを連打する場合は `pressing_x_and_toggle_zr` と記述します。  
これに時間を指定をする場合は、forで繋ぎます。 `pressing_x_and_toggle_zr_for_1sec` となります。  
時間指定には1秒未満も設定することができ、`wait_for_0_65sec` と記述すると、0.65秒間無操作となります。次はいくつか実例を紹介します。  

* toggle_r_for_0_2sec
  * 0.2秒間Rボタンを連打
* wait_for_0_65sec
  * 0.65秒間無操作
* pressing_x_and_pressing_zr_for_0_2sec
  * XボタンとZRボタンを0.2秒間押しっぱなし
* toggle_x_and_toggle_zr_for_0_2sec
  * XボタンとZRボタンを0.2秒間連打

上述したマクロ（ステップ）は、open_macroという構文でも記述できます。次は実際の記述例です。

```
open_macro :sokuwari, steps: [:toggle_r_for_0_2sec, :toggle_thumbr_for_0_14sec, :toggle_thumbr_and_toggle_zr_for_0_34sec, :toggle_r_for_1sec], if_pressed: [:zl, :right]
```

わからないことがあればdiscordで何でも質問してください。

## 左スティックの感度調整
[左スティックの感度調整](/docs/setting/left-analogstick-cap.md)

<!--
## 入力表示
* 使い方は https://github.com/splaplapla/switch-procon-input-viewer を参照してください。
* https://zenn.dev/jiikko/articles/2ef0ccbdfe0fe7 に技術的な解説を書きました
-->

## 設定ファイルの書き方
設定ファイルは、ymlフォーマットに埋め込まれたRubyスクリプトで記述します。  
Rubyスクリプトな上に独特な構文に対して、アレンジを加えることは難しいと思ったので、マウス操作をするだけで設定ファイルを生成するツールを作りました。  
https://splaplapla.github.io/procon_bypass_man_setting_editor/ です。  
このツールで設定ファイルを生成し、コピペをするだけで大半のことは済みます。  
  
TODO 設定ファイルの書き方

## プラグインの書き方
* 後で書きます

## 設定ファイルの書き方がわからない、エラーが起きるとき

設定ファイル(setting.yaml)は、内部がRubyスクリプトになっているので構文エラーが起きることがあります。  
discordで質問してみてください。

## procon_bypass_manのアップグレード方法
[procon_bypass_manのアップグレード方法](/docs/upgrade_pbm.md)

## procon_bypass_man_cloudについて
https://pbm-cloud.jiikko.com/  
procon_bypass_man_cloudの運用をWEBで完結できるようになる無料のWEBサービスです。  
  
procon_bypass_man_cloudとの接続が完了後、Raspberry Piを起動時にprocon_bypass_manが自動で立ち上がるように設定すれば、Raspberry Piへのログインが不要で設定ファイルの変更やprocon_bypass_man自体のアップグレードができます。  
セットアップ方法などでわからないことがあればdiscordで質問してみてください。  
  
セットアップ方法は https://pbm-cloud.jiikko.com/faq に書いています。

## シリアルポート連携
* [ラズベリーパイのシリアルポート(GPIO)へ書き込んでPBM経由してSwitchへ入力をする方法](/docs/setting/integration_external_input_serial_port.md)
* [ラズベリーパイのシリアルポート(GPIO)に書き込むフォーマットについて](/docs/setting/integration_external_input_serial_port_format.md)

## TCPIP連携
procon_bypass_man: 0.3.8 からTCP/IP経由で入力ができるようになりました。  
書き込みフォーマットはJSONのみに対応しています。JSONの詳細な仕様については  [ラズベリーパイのシリアルポート(GPIO)に書き込むフォーマットについて](/docs/setting/integration_external_input_serial_port_format.md) を参照してください。  

次は、PBM側の設定方法についてです。app.rbに以下の行を追加すると、連携するためのTCPサーバを起動するようになります。

```diff
+ config.external_input_channels = [
+   ProconBypassMan::ExternalInput::Channels::TCPIPChannel.new(port: 9000),
+ ]
```

クライアント側のサンプル実装は次の通りです。これを実行するとAボタンを入力します。

```ruby
socket = TCPSocket.new('ras1.local', 9000)
json = { buttons: [:a] }.to_json
message = "#{json}\r\n"
socket.write(message)
puts socket.gets
```

## 最適化について
本稿では、Rubyの最適化について書きます。上級者向けです。適用しなくても普通に動きますが、逆に適用したことで何らかのケースで遅くなる場合があるかもしれません。

* jemallocを使う
  * GCの回数が減る(はずな)ので小さな遅延が減ると考えています。が、違いを測定および体感はできませんでした。
      * インストール方法と動作確認
          * sudo apt install libjemalloc-dev
          * export LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libjemalloc.so.2
          * MALLOC_CONF=stats_print:true ruby -e "exit"
      * 適用方法
          * `/usr/share/pbm/current/systemd_units/pbm.service` の `ExecStart` 行に `LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libjemalloc.so.2` を足してください
          * ex) `ExecStart=/bin/bash -c "LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libjemalloc.so.2 /home/pi/.rbenv/versions/3.0.1/bin/ruby /usr/share/pbm/current/app.rb"`
* jitを有効にする
  * 起動した直後は、コンパイルが走るので遅くなります。しかし、有効にしたところで本プログラムはIOバインドなので効果は薄いようです。
      * 適用方法
          * `/usr/share/pbm/current/systemd_units/pbm.service` の `ExecStart` 行に `--jit` を足してください
          * ex) `ExecStart=/bin/bash -c "/home/pi/.rbenv/versions/3.0.1/bin/ruby --jit /usr/share/pbm/current/app.rb"`
* ラズベリーパイのGUIをオフにする

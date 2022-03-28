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
* [レイヤー](#レイヤー)
* モード
* [マクロ](#マクロ)
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
あらかじめレイヤーごとにキーの配置を設定しておき、用途に応じてレイヤーを切り替えることで違うキーが入力できるという機能です。  
レイヤーは、up, down, left, rightの4つあります。 設定ファイルの書いている `prefix_keys_for_changing_layer` を押しながら、十字キーのup, down, left, rightのどれかを押すと、レイヤーを変更することができます。  
  
レイヤー毎の定義方法は、 `layer` ブロックで囲って定義します。  
以下の例は、upレイヤーとleftレイヤーだけに設定が書かれています。ゲーム進行状況によってレイヤーを切り替えてください。  
初期レイヤーは、 up です。

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

## モード
* 後で書きます

## マクロ

決まった入力を繰り返し実行できる機能を「マクロ」と呼んでいます。  
スプラトゥーンであれば、バブル即割の操作や、試合中の味方へのスーパージャンプもマクロ経由で入力できます。  
  
マクロの実態はただの文字列で`toggle_r_for_0_2sec` や `toggle_r_for_1sec`といった時間指定もできますし、`[:x, :down, :a, :a]` のような1文字のずつの入力も可能です。  
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

マクロの形式には、1ボタンずつ入力する「バージョン1」と時間指定のできる「バージョン2」があります。  
バージョン1は、 `[:x, :y, :up]` と記述すると、x, y, 十字キーの上ボタンを順番に入力します。バージョン1では実行時間を指定することはできません。  
  
バージョン2では、 複数のボタンを同時に、時間を指定して「連打」「押しっぱなし」「無操作」ができます。  
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

上述したマクロ（ステップ）は、open_macroで記述できます。次は実際の記述例です。

```
open_macro :sokuwari, steps: [:toggle_r_for_0_2sec, :toggle_thumbr_for_0_14sec, :toggle_thumbr_and_toggle_zr_for_0_34sec, :toggle_r_for_1sec], if_pressed: [:zl, :right]
```

わからないことがあればdiscordで何でも質問してください。

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

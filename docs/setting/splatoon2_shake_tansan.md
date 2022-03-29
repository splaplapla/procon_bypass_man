# スプラトゥーン2: タンサンボムを貯めるマクロの設定方法

https://user-images.githubusercontent.com/1664497/160649435-52b084ed-05b0-4c58-88ba-667b5f256405.mp4

* procon_bypass_man: 0.1.22以上が必要です
* 左スティックを高速に左右にシェイクするマクロです
* タンサンボムを貯めるのに使えます

## 1. layer内にopen_macroを記述します
* `setting.yml` のlayer内に`open_macro :shake, steps: [:shake_left_stick_and_toggle_b_for_0_1sec], if_pressed: [:b, :r], force_neutral: [:b]` と書きます

## 2. 設定を反映させる
* 上記の記述を加えたsetting.ymlを起動中のprocon_bypass_manプロセスで読み込むには、プロセスにその旨を伝える必要があります
    * ラズベリーパイを再起動して、プロセスを立ち上げ直す、でも目的は達成できますが、もっと簡単にsetting.ymlを再読み込みする必要があります
* 書き換えたsetting.ymlを、起動中のprocon_bypass_manプロセスへ即時反映するには、procon_bypass_manプロセスを動かしたまま、別のshellから 以下をを実行してください
    * setting.ymlのシンタックスが正しければ、switchとの接続が継続したままsetting.ymlの内容を読み込んでいるはずです

```shell
sudo kill -USR2 `cat ./pbm_pid`
```

## 設定例1
```yaml
version: 1.0
setting: |-
  prefix_keys_for_changing_layer [:zr, :zl, :l]

  layer :up do
    open_macro :shake, steps: [:shake_left_stick_and_toggle_b_for_0_1sec], if_pressed: [:b, :r], force_neutral: [:b]
  end
```

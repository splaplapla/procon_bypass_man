# Raspberry Pi4とプロコンの接続方法
## USB経由
* ケーブルに接続するだけ

## Bluetooth経由
* Switch本体の電源を落とす
* $ bluetoothctl
    * -> scan on
* プロコンのリセットボタンを長押しする
  * `[NEW] Device 98:B6:E9:XX:XX:XX Pro Controller` という出力が出る
* 長押ししながら、pair, trust, connect を入力していく
* Connection successfulが出力されて、プロコンのLEDランプが点滅し続ければ成功

```
[bluetooth]# pair 98:B6:E9:XX:XX:XX
Attempting to pair with 98:B6:E9:XX:XX:XX
[bluetooth]# trust 98:B6:E9:XX:XX:XX
[bluetooth]# connect 98:B6:E9:XX:XX:XX
Attempting to connect to 98:B6:E9:XX:XX:XX
Changing 98:B6:E9:XX:XX:XX trust succeeded
Pairing successful
Connection successful
```

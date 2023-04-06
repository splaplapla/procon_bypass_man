# ラズベリーパイのシリアルポート(GPIO)に書き込むフォーマットについて
* procon_bypass_man: 0.3.7からGPIOを経由してSwitchへ入力できるようになりました。本テキストではPBMが読み取れるフォーマットについて記載します

## フォーマット
JSON形式, plain textに対応しています

* JSON形式
    * 受付可能なカラム
      * hex
        * 16進数でエンコードした`INPUT 0x30` を書いてください。スティック操作を除くボタン部分のみが読み込まれます
        * https://github.com/dekuNukem/Nintendo_Switch_Reverse_Engineering/blob/ac8093c84194b3232acb675ac1accce9bcb456a3/bluetooth_hid_notes.md#input-0x30
        * ex: '30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000'
      * buttons
        * 「入力したいボタン」「入力したくないボタン」を配列で渡してください
        * 「入力したいボタン」
             * `"y", "x", "b", "a", "sl", "sr", "r", "zr", "minus", "plus", "thumbr", "thumbl", "home", "cap", "down", "up", "right", "left", "l", "zl"`
        * 「入力したくないボタン」
             * `"uny", "unx", "unb", "una", "unsl", "unsr", "unr", "unzr", "unminus", "unplus", "unthumbr", "unthumbl", "unhome", "uncap", "undown", "unup", "unright", "unleft", "unl", "unzl"`
        * ex: `['a', 'b']`
    * 仕様
       * JSONにhex, buttonsの両方が含まれている場合、hexを優先し、buttonsは無視します
    * JSONの例
      * `'{"hex":"30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000", "buttons": ["a"] }'`
* plain text
  * コロンで囲ったボタンを1つの入力として解釈します
  * `:a::b::uny:` を入力した場合には、a, b, uny を読み込みます

## 正しいJSONかを検証する
本リポジトリにJSONを検証する `bin/validate_external_input` を同梱しています。実行例を以下に示します。

```shell
$ echo '{"hex":"30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000", "buttons": ["a"] }' | bin/validate_external_input
読み取った値: {:hex=>"30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000", :buttons=>[:a]}
```

以上。

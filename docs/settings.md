# 設定ファイルの仕様
## トップレベル

<table>
  <tr>
    <th>名前</th>
    <th>引数</th>
    <th>Default</th>
    <th>必須</th>
  </tr>
    <tr>
      <td>install_macro_plugin</td>
      <td>プラグインの名前</td>
      <td>なし</td>
      <td>No</td>
    </tr>
    <tr>
      <td>install_mode_plugin</td>
      <td>プラグインの名前</td>
      <td>なし</td>
      <td>No</td>
    </tr>
    <tr>
      <td>prefix_keys_for_changing_layer</td>
      <td>ボタンの配列</td>
      <td>なし</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td>layer</td>
      <td>direction(up, down, left, right), mode</td>
      <td>なし</td>
      <td>Yes</td>
    </tr>
</table>

## レイヤーレベル

<table>
  <tr>
    <th>名前</th>
    <th>引数</th>
    <th>必須</th>
  </tr>
    <tr>
      <td>flip</td>
      <td>対象のボタン, if_pressed, force_neutral</td>
      <td>No</td>
    </tr>
    <tr>
      <td>macro</td>
      <td>プラグインのクラス, if_pressed</td>
      <td>No</td>
    </tr>
    <tr>
      <td>open_macro</td>
      <td>対象のボタン, if_pressed</td>
      <td>No</td>
    </tr>
    <tr>
      <td>remap</td>
      <td>対象のボタン, to</td>
      <td>No</td>
    </tr>
</table>

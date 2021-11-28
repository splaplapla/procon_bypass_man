# クラス変数のstatsを書き換える
# 定期的に送信、ステータスが変わった時とプロセス終了時に送信
class ProconBypassMan::DeviceStatus
  RUNNING = :running
  CONNECTED_BUT_SLEEPING = :connected_but_sleeping # コードはつながっているが、switchがsleepしているとき
  DEVICE_ERROR = :device_error # 繋がっていないとか、デバイスが使えない時
  CONNECTED_BUT_ERROR = :connected_but_error # 実行時エラーあたり
  CONNECTED_BUT_SETTING_SYNTAX_ERROR = :connected_but_setting_syntax_error
end

# 定期的に送信、ステータスが変わった時とプロセス終了時に送信
class ProconBypassMan::DeviceStatus
  INITIALIZED = :initialized
  RUNNING = :running
  CONNECTED_BUT_SLEEPING = :connected_but_sleeping # コードはつながっているが、switchがsleepしているとき
  DEVICE_ERROR = :device_error # 繋がっていないとか、デバイスが使えない時
  CONNECTED_BUT_ERROR = :connected_but_error # 実行時エラーあたり
  CONNECTED_BUT_SETTING_SYNTAX_ERROR = :connected_but_setting_syntax_error

  @@status = nil

  def self.current
    @@status || INITIALIZED
  end

  def self.change_to_running!
    @@status = RUNNING
  end

  def self.change_to_connected_but_sleeping!
    @@status = CONNECTED_BUT_SLEEPING
  end

  def self.change_to_device_error!
    @@status = DEVICE_ERROR
  end

  def self.change_to_connected_but_error!
    @@status = CONNECTED_BUT_ERROR
  end

  def self.change_to_connected_but_setting_syntax_error!
    @@status = CONNECTED_BUT_SETTING_SYNTAX_ERROR
  end
end

class ProconBypassMan::DeviceStatus
  INITIALIZED = :initialized
  RUNNING = :running
  CONNECTED_BUT_SLEEPING = :connected_but_sleeping # コードはつながっているが、switchがsleepしているとき
  PROCON_NOT_FOUND_ERROR = :procon_not_found_error # 繋がっていないとか、デバイスが使えない時
  CONNECTED_BUT_ERROR = :connected_but_error # 実行時エラーあたり
  SETTING_SYNTAX_ERROR_AND_SHUTDOWN = :setting_syntax_error_and_shutdown

  @@status = nil

  def self.current
    @@status || INITIALIZED
  end

  def self.change_to_running!
    @@status = RUNNING
    ProconBypassMan::SyncDeviceStatsJob.perform_async(ProconBypassMan::DeviceStatus.current)
  end

  def self.change_to_connected_but_sleeping!
    @@status = CONNECTED_BUT_SLEEPING
    ProconBypassMan::SyncDeviceStatsJob.perform_async(ProconBypassMan::DeviceStatus.current)
  end

  def self.change_to_procon_not_found_error!
    @@status = PROCON_NOT_FOUND_ERROR
    ProconBypassMan::SyncDeviceStatsJob.perform_async(ProconBypassMan::DeviceStatus.current)
  end

  def self.change_to_device_error!
    @@status = DEVICE_ERROR
    ProconBypassMan::SyncDeviceStatsJob.perform_async(ProconBypassMan::DeviceStatus.current)
  end

  def self.change_to_connected_but_error!
    @@status = CONNECTED_BUT_ERROR
    ProconBypassMan::SyncDeviceStatsJob.perform_async(ProconBypassMan::DeviceStatus.current)
  end

  def self.change_to_setting_syntax_error_and_shutdown!
    @@status = SETTING_SYNTAX_ERROR_AND_SHUTDOWN
    ProconBypassMan::SyncDeviceStatsJob.perform_async(ProconBypassMan::DeviceStatus.current)
  end
end

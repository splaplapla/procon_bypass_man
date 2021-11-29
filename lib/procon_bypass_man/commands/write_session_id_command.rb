class ProconBypassMan::WriteSessionIdCommand
  # @return [String] session_id ラズパイが起動してからshutdownするまで同じ文字列を返す
  # 起動すると/tmp がなくなる前提の実装
  def self.execute
    @@session_id ||= "s_#{SecureRandom.uuid}"
  end
end

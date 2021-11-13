class ProconBypassMan::WriteSessionIdCommand
  # @return [String] session_id ラズパイが起動してからshutdownするまで同じ文字列を返す
  # 起動すると/tmp がなくなる前提の実装
  def self.execute
    path = "/tmp/pbm_session_id"
    if(sid = File.read(path))
      return sid
    end
  rescue Errno::ENOENT
    File.write(path, SecureRandom.uuid)
    return SecureRandom.uuid
  end
end

class ProconBypassMan::SaveMachineIdentifierCommand
  def self.execute
    path = "#{ProconBypassMan.root}/mathine_id"
    if(sid = File.read(path))
      return sid
    end
  rescue Errno::ENOENT
    File.write(path, "m_#{SecureRandom.uuid}")
    return SecureRandom.uuid
  end
end

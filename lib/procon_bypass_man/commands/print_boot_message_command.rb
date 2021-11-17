class ProconBypassMan::PrintBootMessageCommand
  # @return [void]
  def self.execute
    message = ProconBypassMan::BootMessage.new
    ProconBypassMan::BootReporter.perform_async(message.to_hash)
    ProconBypassMan::BootReporter.perform_async(ProconBypassMan.config.raw_setting)
    puts message.to_s
  end
end

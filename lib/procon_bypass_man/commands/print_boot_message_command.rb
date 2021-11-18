class ProconBypassMan::PrintBootMessageCommand
  # @return [void]
  def self.execute
    message = ProconBypassMan::BootMessage.new
    ProconBypassMan::ReportBootJob.perform_async(message.to_hash)
    ProconBypassMan::ReportBootJob.perform_async(ProconBypassMan.config.raw_setting)
    puts message.to_s
  end
end

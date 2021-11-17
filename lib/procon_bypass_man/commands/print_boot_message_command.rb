class ProconBypassMan::PrintBootMessageCommand
  # @return [void]
  def self.execute
    message = ProconBypassMan::BootMessage.new

    ProconBypassMan::Outbound::Worker.push(
      body: ProconBypassMan.config.raw_setting,
      reporter_class: ProconBypassMan::BootReporter,
    )
    ProconBypassMan::Outbound::Worker.push(
      body: message.to_hash,
      reporter_class: ProconBypassMan::BootReporter,
    )
    puts message.to_s
  end
end

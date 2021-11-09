class ProconBypassMan::PrintBootMessageCommand
  # @return [void]
  def self.execute
    message = ProconBypassMan::BootMessage.new
    ProconBypassMan::Outbound::Worker.push(
      data: message.to_hash,
      reporter_class: ProconBypassMan::Reporter,
    )
    puts message.to_s
  end
end

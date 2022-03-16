class ProconBypassMan::RemoteMacroSender
  def self.execute(action: , uuid: , steps: )
    ProconBypassMan.logger.info "[remote macro][sender] action: #{action}, uuid: #{uuid}, steps: #{steps}"
    ProconBypassMan::QueueOverProcess.push(ProconBypassMan::RemoteMacro::Task.new(action, uuid, steps))
  end
end

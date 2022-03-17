class ProconBypassMan::RemoteMacroSender
  def self.execute(name: , uuid: , steps: )
    ProconBypassMan.logger.info "[remote macro][sender] name: #{name}, uuid: #{uuid}, steps: #{steps}"
    ProconBypassMan::QueueOverProcess.push(ProconBypassMan::RemoteMacro::Task.new(name, uuid, steps))
  end
end

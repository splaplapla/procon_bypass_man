# FIXME: RemoteMacroSenderという名前をやめる。BypassProcessSenderみたいにする
class ProconBypassMan::RemoteMacroSender
  def self.execute(name: , uuid: , steps: , type: )
    ProconBypassMan.logger.info "[remote macro][sender] name: #{name}, uuid: #{uuid}, steps: #{steps}, type: #{type}"
    ProconBypassMan::RemoteMacro::QueueOverProcess.push(
      ProconBypassMan::RemoteMacro::Task.new(name, uuid, steps, type)
    )
  end
end

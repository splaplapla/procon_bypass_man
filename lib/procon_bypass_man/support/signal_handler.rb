module ProconBypassMan::SignalHandler
  def handle_signal(sig)
    ProconBypassMan.logger.info "#{$$}で#{sig}を受け取りました"
    case sig
    when 'USR2'
      raise ProconBypassMan::Runner::InterruptForRestart
    when 'INT', 'TERM'
      raise Interrupt
    end
  end
end

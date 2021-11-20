require_relative "io_monitor"
require_relative "uptime"
require_relative "boot_message"
require_relative "background/job_runner"
require_relative "signal_handler"

class ProconBypassMan::Runner
  class InterruptForRestart < StandardError; end

  include ProconBypassMan::SignalHandler

  def initialize(gadget: , procon: )
    @gadget = gadget
    @procon = procon

    ProconBypassMan::PrintBootMessageCommand.execute
  end

  def run
    self_read, self_write = IO.pipe
    %w(TERM INT USR1 USR2).each do |sig|
      begin
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        ProconBypassMan::SendErrorCommand.execute(error: "Signal #{sig} not supported")
      end
    end

    loop do
      $will_terminate_token = false
      # TODO forkしないでThreadでいいのでは？
      main_loop_pid = Kernel.fork { ProconBypassMan::BypassCommand.new(gadget: @gadget, procon: @procon).execute }

      begin
        while(readable_io = IO.select([self_read]))
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue InterruptForRestart
        $will_terminate_token = true
        Process.kill("TERM", main_loop_pid)
        Process.wait
        ProconBypassMan.logger.info("Reloading config file")
        begin
          ProconBypassMan::ButtonsSettingConfiguration::Loader.reload_setting
          ProconBypassMan::SendReloadConfigEventCommand.execute
        rescue ProconBypassMan::CouldNotLoadConfigError
          ProconBypassMan::SendErrorCommand.execute(error: "設定ファイルが不正です。再読み込みができませんでした")
        end
        ProconBypassMan.logger.info("バイパス処理を再開します")
      rescue Interrupt
        $will_terminate_token = true
        Process.kill("TERM", main_loop_pid)
        Process.wait
        @gadget&.close
        @procon&.close
        FileUtils.rm_rf(ProconBypassMan.pid_path)
        FileUtils.rm_rf(ProconBypassMan.digest_path)
        exit 1
      end
    end
  end
end

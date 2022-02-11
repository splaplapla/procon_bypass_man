require_relative "io_monitor"

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
      # NOTE メインプロセスではThreadをいくつか起動しているので念のためパフォーマンスを優先するためにforkしていく
      child_pid = Kernel.fork { ProconBypassMan::BypassCommand.new(gadget: @gadget, procon: @procon).execute }

      begin
        # TODO 小プロセスが消滅した時に、メインプロセスは生き続けてしまい、何もできなくなる問題がある
        while(readable_io = IO.select([self_read]))
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue InterruptForRestart
        $will_terminate_token = true
        Process.kill("TERM", child_pid)
        Process.wait
        ProconBypassMan::PrintMessageCommand.execute(text: "Reloading config file")
        begin
          ProconBypassMan::ButtonsSettingConfiguration::Loader.reload_setting
          ProconBypassMan::SendReloadConfigEventCommand.execute

          if File.exist?(ProconBypassMan.fallback_setting_path)
            FileUtils.rm_rf(ProconBypassMan.fallback_setting_path)
          end
        rescue ProconBypassMan::CouldNotLoadConfigError => error
          ProconBypassMan::SendErrorCommand.execute(error: "設定ファイルが不正です。再読み込みができませんでした")
          ProconBypassMan::ReportErrorReloadConfigJob.perform_async(error.message)

          if File.exist?(ProconBypassMan.fallback_setting_path)
            FileUtils.copy(
              ProconBypassMan.fallback_setting_path,
              ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path,
            )
            FileUtils.rm_rf(ProconBypassMan.fallback_setting_path)
          end
        end
        ProconBypassMan::PrintMessageCommand.execute(text: "バイパス処理を再開します")
      rescue Interrupt
        $will_terminate_token = true
        Process.kill("TERM", child_pid)
        Process.wait
        ProconBypassMan::PrintMessageCommand.execute(text: "処理を終了します")
        @gadget&.close
        @procon&.close
        break
      end
    end
  end
end

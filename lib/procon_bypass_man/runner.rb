# フォアグラウンドで実行する
class ProconBypassMan::Runner
  def initialize(gadget: , procon: )
    @gadget = gadget
    @procon = procon
  end

  def run
    self_read, self_write = IO.pipe
    %w(TERM INT USR2).each do |sig|
      begin
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        ProconBypassMan::SendErrorCommand.execute(error: "Signal #{sig} not supported")
      end
    end

    loop do
      child_pid = Kernel.fork do
        $will_terminate_token = false
        ProconBypassMan.run_on_after_fork_of_bypass_process
        ProconBypassMan::BypassCommand.new(gadget: @gadget, procon: @procon).execute # ここでblockingする
        next
      end

      begin
        # TODO 子プロセスが消滅した時に、メインプロセスは生き続けてしまい、何もできなくなる問題がある
        while(readable_io = IO.select([self_read]))
          signal = readable_io.first[0].gets.strip
          ProconBypassMan.logger.debug "[BYPASS] MASTERプロセスで#{signal}シグナルを受け取りました"
          case signal
          when 'USR2'
            raise ProconBypassMan::InterruptForRestart
          when 'INT', 'TERM'
            raise Interrupt
          end
        end
      rescue ProconBypassMan::InterruptForRestart
        ProconBypassMan::PrintMessageCommand.execute(text: "設定ファイルの再読み込みを開始します")
        Process.kill("USR2", child_pid)
        Process.wait
        begin
          ProconBypassMan::ButtonsSettingConfiguration::Loader.reload_setting
          ProconBypassMan::SendReloadConfigEventCommand.execute
        rescue ProconBypassMan::CouldNotLoadConfigError => error
          ProconBypassMan::SendErrorCommand.execute(error: "設定ファイルが不正です。再読み込みができませんでした")
          ProconBypassMan::ReportErrorReloadConfigJob.perform_async(error.message)
        end
        ProconBypassMan::PrintMessageCommand.execute(text: "バイパス処理を再開します")
      rescue Interrupt
        puts
        ProconBypassMan::PrintMessageCommand.execute(text: "[MASTER] BYPASSプロセスにTERMシグナルを送信します")
        Process.kill("TERM", child_pid)
        ProconBypassMan::PrintMessageCommand.execute(text: "[MASTER] BYPASSプロセスの終了を待ちます")
        Process.wait
        break
      end
    end

    ProconBypassMan::PrintMessageCommand.execute(text: "[MASTER] メインプロセスを終了します")
  end
end

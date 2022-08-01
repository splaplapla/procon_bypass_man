class ProconBypassMan::Runner
  class InterruptForRestart < StandardError; end

  include ProconBypassMan::SignalHandler

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
      # NOTE メインプロセスではThreadをいくつか起動しているので念のためパフォーマンスを優先するためにforkしていく
      child_pid = Kernel.fork do
        $will_terminate_token = false
        DRb.start_service if defined?(DRb)
        BlueGreenProcess.configure do |config|
          config.after_fork = -> {
            DRb.start_service if defined?(DRb)
            ProconBypassMan::Background::JobRunner.start!
          }
        end
        ProconBypassMan::RemoteMacroReceiver.start!
        ProconBypassMan::ProconDisplay::Server.start!
        ProconBypassMan::BypassCommand.new(gadget: @gadget, procon: @procon).execute # ここでblockingする
        next
      end

      begin
        # TODO 子プロセスが消滅した時に、メインプロセスは生き続けてしまい、何もできなくなる問題がある
        while(readable_io = IO.select([self_read]))
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue InterruptForRestart
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
        ProconBypassMan::PrintMessageCommand.execute(text: "処理を終了します")
        Process.kill("TERM", child_pid)
        Process.wait
        break
      end
    end
  end
end

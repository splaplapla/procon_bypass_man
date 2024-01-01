# 子プロセスで実行する
class ProconBypassMan::BypassCommand
  module WILL_TERMINATE_TOKEN
    TERMINATE = :terminate
    RESTART = :restart
  end

  def initialize(gadget: , procon: )
    @gadget = gadget
    @procon = procon
  end

  def execute
    self_read, self_write = IO.pipe
    %w(TERM INT USR2).each do |sig|
      begin
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        puts "プロセスでSignal #{sig} not supported"
      end
    end

    # gadget => procon
    # 遅くていい
    ProconBypassMan.logger.info "[BYPASS] Thread1を起動します"

    cycle_sleep = ProconBypassMan::CycleSleep.new(cycle_interval: 1, execution_cycle: ProconBypassMan.config.bypass_mode.gadget_to_procon_interval)

    t1 = Thread.new do
      bypass = ProconBypassMan::Bypass::SwitchToProcon.new(gadget: @gadget, procon: @procon)
      loop do
        break if $will_terminate_token

        cycle_sleep.sleep_or_execute do
          bypass.run
        end
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN => e
        ProconBypassMan::SendErrorCommand.execute(error: "Switchとの切断されました.終了処理を開始します. #{e.full_message}")
        Process.kill "TERM", Process.ppid
      rescue Errno::ETIMEDOUT => e
        # TODO まれにこれが発生する. 再接続したい
        ProconBypassMan::SendErrorCommand.execute(error: "Switchと意図せず切断されました.終了処理を開始します. #{e.full_message}")
        Process.kill "TERM", Process.ppid
      end

      ProconBypassMan.logger.info "[BYPASS] Thread1を終了します"
    end

    # procon => gadget
    # シビア
    t2 = Thread.new do
      bypass = ProconBypassMan::Bypass::ProconToSwitch.new(gadget: @gadget, procon: @procon)
      process = BlueGreenProcess.new(worker_instance: bypass, max_work: 1000)
      loop do
        GC.disable

        if $will_terminate_token
          if $will_terminate_token == WILL_TERMINATE_TOKEN::TERMINATE
            bypass.direct_connect_switch_via_bluetooth
          end
          process.shutdown
          break
        end

        process.work

        process_switching_time_before_work = BlueGreenProcess.performance.process_switching_time_before_work
        if process_switching_time_before_work > 0.2
          ProconBypassMan::SendWarningCommand.execute(warning: "[PERFORMANCE] BlueGreenProcess.performance.process_switching_time_before_work: #{process_switching_time_before_work}", stdout: false)
        end

      rescue EOFError => e
        ProconBypassMan::SendErrorCommand.execute(error: "Proconが切断されました。終了処理を開始します. #{e.full_message}")
        Process.kill "TERM", Process.ppid
        process.shutdown
        break
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError, Errno::ESHUTDOWN => e
        ProconBypassMan::SendErrorCommand.execute(error: "Proconが切断されました。終了処理を開始します2. #{e.full_message}")
        Process.kill "TERM", Process.ppid
        process.shutdown
        break
      end

      ProconBypassMan.logger.info "[BYPASS] Thread2を終了します"
    end

    ProconBypassMan.logger.info "BYPASSプロセスでgraceful shutdownの準備ができました"
    begin
      # TODO: 本当はいらないんだけど、なぜか反映されないのでここでも設定する
      BlueGreenProcess.config.logger = ProconBypassMan.logger

      while(readable_io = IO.select([self_read]))
        signal = readable_io.first[0].gets.strip
        case signal
        when 'USR2'
          ProconBypassMan.logger.debug "[BYPASS] BYPASSプロセスでUSR2シグナルを受け取りました"
          raise ProconBypassMan::InterruptForRestart
        when 'TERM'
          ProconBypassMan.logger.debug "[BYPASS] BYPASSプロセスでTERMシグナルを受け取りました"
          raise Interrupt
        when 'INT'
          ProconBypassMan.logger.debug "[BYPASS] BYPASSプロセスでINTシグナルを無視します"
        end
      end
    rescue ProconBypassMan::InterruptForRestart
      ProconBypassMan.logger.info "[BYPASS] BYPASSプロセスの終了処理を開始します"
      $will_terminate_token = WILL_TERMINATE_TOKEN::RESTART
      BlueGreenProcess.terminate_workers_immediately
      [t1, t2].each(&:join)
      ProconBypassMan.logger.info "[BYPASS] BYPASSプロセス内のThreadsが停止しました"
      @gadget&.close
      @procon&.close
      ProconBypassMan.logger.info "[BYPASS] BYPASSプロセスを終了します"
      DRb.stop_service if defined?(DRb)
      exit! 1 # child processなのでexitしていい
    rescue Interrupt
      ProconBypassMan.logger.info "[BYPASS] BYPASSプロセスの終了処理を開始します"
      $will_terminate_token = WILL_TERMINATE_TOKEN::TERMINATE
      BlueGreenProcess.terminate_workers_immediately
      [t1, t2].each(&:join)
      ProconBypassMan.logger.info "[BYPASS] BYPASSプロセス内のThreadsが停止しました"
      @gadget&.close
      @procon&.close
      ProconBypassMan.logger.info "[BYPASS] BYPASSプロセスを終了します"
      DRb.stop_service if defined?(DRb)
      exit! 1 # child processなのでexitしていい
    end
  end
end

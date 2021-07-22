require_relative "io_monitor"

class ProconBypassMan::Runner
  class InterruptForRestart < StandardError; end

  def initialize
    $will_interval_0_0_0_5 = 0
    $will_interval_1_6 = 0
  end

  def run
    first_negotiation
    print_booted_message

    self_read, self_write = IO.pipe
    %w(TERM INT USR1 USR2).each do |sig|
      begin
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        ProconBypassMan.logger.error("Signal #{sig} not supported")
      end
    end

    loop do
      $will_terminate_token = false
      main_loop_pid = fork { main_loop }

      begin
        while readable_io = IO.select([self_read])
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue InterruptForRestart
        $will_terminate_token = true
        Process.kill("TERM", main_loop_pid)
        Process.wait
        ProconBypassMan.logger.info("Reloading config file")
        begin
          ProconBypassMan::Configuration::Loader.reload_setting
          puts "設定ファイルの再読み込みができました"
        rescue ProconBypassMan::CouldNotLoadConfigError
          ProconBypassMan.logger.error "設定ファイルが不正です。再読み込みができませんでした"
        end
        ProconBypassMan.logger.info("バイパス処理を再開します")
      rescue Interrupt
        $will_terminate_token = true
        Process.kill("TERM", main_loop_pid)
        Process.wait
        @gadget&.close
        @procon&.close
        FileUtils.rm_rf(ProconBypassMan.pid_path)
        exit 1
      end
    end
  end

  private

  def main_loop
    # TODO 接続確立完了をswitchを読み取るようにして、この暫定で接続完了sleepを消す
    Thread.new do
      sleep(5)
      $will_interval_0_0_0_5 = 0.005
      $will_interval_1_6 = 1.6
    end

    ProconBypassMan::IOMonitor.start!
    # gadget => procon
    # 遅くていい
    monitor1 = ProconBypassMan::IOMonitor.new(label: "switch -> procon")
    monitor2 = ProconBypassMan::IOMonitor.new(label: "procon -> switch")
    ProconBypassMan.logger.info "Thread1を起動します"
    t1 = Thread.new do
      bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor1)
      begin
        loop do
          break if $will_terminate_token
          bypass.send_gadget_to_procon!
        rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
          ProconBypassMan.logger.error "Proconが切断されました.終了処理を開始します"
          Process.kill "TERM", Process.ppid
        end
        ProconBypassMan.logger.info "Thread1を終了します"
      end
    end

    # procon => gadget
    # シビア
    ProconBypassMan.logger.info "Thread2を起動します"
    t2 = Thread.new do
      bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor2)
      begin
        loop do
          break if $will_terminate_token
          bypass.send_procon_to_gadget!
        rescue EOFError => e
          ProconBypassMan.logger.error "Proconと通信ができませんでした.終了処理を開始します"
          Process.kill "TERM", Process.ppid
        rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
          ProconBypassMan.logger.error "Proconが切断されました。終了処理を開始します"
          Process.kill "TERM", Process.ppid
        end
        ProconBypassMan.logger.info "Thread2を終了します"
      end
    end

    self_read, self_write = IO.pipe
    %w(TERM INT).each do |sig|
      begin
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        puts "プロセスでSignal #{sig} not supported"
      end
    end

    ProconBypassMan.logger.info "子プロセスでgraceful shutdownの準備ができました"
    begin
      while readable_io = IO.select([self_read])
        signal = readable_io.first[0].gets.strip
        handle_signal(signal)
      end
    rescue Interrupt
      $will_terminate_token = true
      [t1, t2].each(&:join)
      @gadget&.close
      @procon&.close
      exit 1
    end
  end

  def first_negotiation
    return if $will_terminate_token

    s = ProconBypassMan::BypassSupporter.new(throw_error_if_timeout: true, enable_at_exit: false)
    # おきまり
    s.read_switch # >>> 0000
    s.read_switch # >>> 0000
    s.read_switch # >>> 8005
    s.read_switch # >>> 0000
    # ハンドシェイクの開始
    s.read_switch # >>> 8001 を要求
    s.read_procon # <<< 81010003176d96e7a5480000000, macaddressとコントローラー番号を返す
    # ハンドシェイクの開始
    s.read_switch # >>> 8002
    s.read_procon # <<< 8102000000000000000
    # -----
    s.read_switch # >>> 01000000000000000000033000000
    s.read_procon # <<< ^21
    # ------
    s.read_switch # 本当なら8004 が返ってくるはず

    @gadget = s.switch
    @procon = s.procon
  rescue ProconBypassMan::Timer::Timeout
    ::ProconBypassMan.logger.error "デバイスとの通信でタイムアウトが起きて接続ができませんでした。"
    @gadget&.close
    @procon&.close
    raise ::ProconBypassMan::EternalConnectionError
  end

  def handle_signal(sig)
    ProconBypassMan.logger.info "#{$$}で#{sig}を受け取りました"
    case sig
    when 'USR2'
      raise InterruptForRestart
    when 'INT', 'TERM'
      raise Interrupt
    end
  end

  # @return [void]
  def print_booted_message
    booted_message = <<~EOF
      ----
      RUBY_VERSION: #{RUBY_VERSION}
      ProconBypassMan: #{ProconBypassMan::VERSION}
      pid: #{$$}
      root: #{ProconBypassMan.root}
      pid_path: #{ProconBypassMan.pid_path}
      setting_path: #{ProconBypassMan::Configuration.instance.setting_path}
      ----
    EOF
    ProconBypassMan.logger.info(booted_message)
    puts booted_message
  end
end

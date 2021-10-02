require_relative "io_monitor"
require_relative "uptime"
require_relative "boot_message"

class ProconBypassMan::Runner
  class InterruptForRestart < StandardError; end

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
        FileUtils.rm_rf(ProconBypassMan.digest_path)
        exit 1
      end
    end
  end

  private

  def main_loop
    ProconBypassMan::IOMonitor.start!
    # gadget => procon
    # 遅くていい
    monitor1 = ProconBypassMan::IOMonitor.new(label: "switch -> procon")
    monitor2 = ProconBypassMan::IOMonitor.new(label: "procon -> switch")
    ProconBypassMan.logger.info "Thread1を起動します"
    t1 = Thread.new do
      bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor1)
      loop do
        break if $will_terminate_token
        bypass.send_gadget_to_procon!
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
        ProconBypassMan.logger.error "Proconが切断されました.終了処理を開始します"
        Process.kill "TERM", Process.ppid
      rescue Errno::ETIMEDOUT => e
        # TODO まれにこれが発生する. 再接続したい
        ProconBypassMan::ErrorReporter.report(body: e)
        ProconBypassMan.logger.error "Switchとの切断されました.終了処理を開始します"
        Process.kill "TERM", Process.ppid
      end
      ProconBypassMan.logger.info "Thread1を終了します"
    end

    # procon => gadget
    # シビア
    ProconBypassMan.logger.info "Thread2を起動します"
    t2 = Thread.new do
      bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor2)
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
      while(readable_io = IO.select([self_read]))
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
    @gadget, @procon = ProconBypassMan::DeviceConnector.connect
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
    message = ProconBypassMan::BootMessage.new
    ProconBypassMan.logger.info(message.to_s)
    Thread.new { ProconBypassMan::Reporter.report(body: message.to_hash) }
    puts message.to_s
  end
end

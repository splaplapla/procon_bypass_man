require_relative "io_monitor"

class ProconBypassMan::Runner
  class InterruptForRestart < StandardError; end

  def initialize(gadget: , procon: )
    @gadget = gadget
    @procon = procon

    $will_interval_0_0_0_5 = 0
    $will_interval_1_6 = 0
  end

  def run
    first_negotiation
    $is_stable = false

    self_read, self_write = IO.pipe
    %w(TERM INT USR2).each do |sig|
      begin
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        ProconBypassMan.logger.info("Signal #{sig} not supported")
      end
    end

    FileUtils.mkdir_p "tmp"
    File.write "tmp/pid", $$

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
        exit 1
      end
    end
  end

  private

  def main_loop
    # TODO 接続確立完了をswitchを読み取るようにして、この暫定で接続完了sleepを消す
    Thread.new do
      sleep(10)
      $will_interval_0_0_0_5 = 0.005
      $will_interval_1_6 = 1.6
      $is_stable = true
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
        rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
          ProconBypassMan.logger.error "Proconが切断されました.終了処理を開始します"
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
    loop do
      begin
        input = @gadget.read_nonblock(128)
        ProconBypassMan.logger.debug { ">>> #{input.unpack("H*")}" }
        @procon.write_nonblock(input)
        if input[0] == "\x80".b && input[1] == "\x01".b
          ProconBypassMan.logger.info("first negotiation is over")
          break
        end
        break if $will_terminate_token
      rescue IO::EAGAINWaitReadable
      end
    end
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
end

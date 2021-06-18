require_relative "io_monitor"

class ProconBypassMan::Runner
  def initialize(gadget: , procon: )
    @gadget = gadget
    @procon = procon

    @will_interval_0_0_1 = 0
    @will_interval_1_6 = 0
  end

  def run
    first_negotiation
    main_loop
  end

  private

  def main_loop
    Thread.new do
      sleep(10)
      $will_interval_0_0_1 = 0.01
      $will_interval_1_6 = 1.6
    end

    ProconBypassMan::IOMonitor.start!
    # gadget => procon
    # 遅くていい
    Thread.new do
      monitor = ProconBypassMan::IOMonitor.new(label: "switch -> procon")
      bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor)
      loop do
        bypass.send_gadget_to_procon!
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
        raise ProconBypassMan::ProConRejected.new(e)
      ensure
        @gadget&.close
        @procon&.close
      end
    end

    # procon => gadget
    # シビア
    Thread.new do
      monitor = ProconBypassMan::IOMonitor.new(label: "procon -> switch")
      bypass = ProconBypassMan::Bypass.new(gadget: @gadget, procon: @procon, monitor: monitor)
      loop do
        io_stats do
          bypass.send_procon_to_gadget!
        end
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
        raise ProconBypassMan::ProConRejected.new(e)
      ensure
        @gadget&.close
        @procon&.close
      end
    end

    loop { sleep(5) }
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
      rescue IO::EAGAINWaitReadable
      end
    end
  end
end

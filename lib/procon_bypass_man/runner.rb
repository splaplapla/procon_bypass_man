require_relative "io_stats"

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
      @will_interval_0_0_1 = 0.01
      @will_interval_1_6 = 1.6
    end

    io_stats1 = ProconBypassMan::IOStatus.new(label: "gadget => procon")
    io_stats2 = ProconBypassMan::IOStatus.new(label: "procon => gadget")
    ProconBypassMan::IOStatus.start_monitoring!
    # gadget => procon
    # 遅くていい
    Thread.new do
      io_stats = io_stats1
      loop do
        begin
          # TODO callbackクラス的なオブジェクトでラップする
          io_stats.before_read!
          # NOTE read and writeを分けたほうがいいかも
          input = @gadget.read_nonblock(128)
          io_stats.after_read!
          io_stats.before_write!
          @procon.write_nonblock(input)
          io_stats.after_write!
          sleep(@will_interval_1_6)
        rescue IO::EAGAINWaitReadable
          io_stats.eagain_wait_readable!
          sleep(@will_interval_1_6)
        end
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
        raise ProconBypassMan::ProConRejected.new(e)
      end
    end

    # procon => gadget
    # シビア
    Thread.new do
      io_stats = io_stats2
      loop do
        output = nil
        begin
          io_stats.before_read!
          output = @procon.read_nonblock(128)
          io_stats.after_read!
        rescue IO::EAGAINWaitReadable
          io_stats.eagain_wait_readable!
          retry
        end

        begin
          ProconBypassMan.logger.debug { "<<< #{output.unpack("H*")}" }
          io_stats.before_write!
          @gadget.write_nonblock(
            ProconBypassMan::Processor.new(output).process
          )
          io_stats.after_write!
          sleep(@will_interval_0_0_1)
        rescue IO::EAGAINWaitReadable
          io_stats.eagain_wait_readable!
        end
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
        raise ProconBypassMan::ProConRejected.new(e)
      end
    end

    loop { sleep(5) }
  ensure
    @gadget&.close
    @procon&.close
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

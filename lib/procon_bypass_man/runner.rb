class ProconBypassMan::Runner
  class ProConRejected < StandardError; end

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

    # gadget => procon
    # 遅くていい
    Thread.new do
      loop do
        begin
          # NOTE read and writeを分けたほうがいいかも
          input = @gadget.read_nonblock(128)
          ProconBypassMan.logger(">>> #{input.b}")
          @procon.write_nonblock(input)
          sleep(@will_interval_1_6)
        rescue IO::EAGAINWaitReadable
          sleep(@will_interval_1_6)
        end
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
        raise ProConRejected.new(e)
      end
    end

    # procon => gadget
    # シビア
    Thread.new do
      loop do
        output = nil
        begin
          output = @procon.read_nonblock(128)
        rescue IO::EAGAINWaitReadable
          retry
        end

        begin
          ProconBypassMan.logger("<<< #{output.b}")
          @gadget.write_nonblock(
            ProconBypassMan::Processor.new(output).process
          )
          sleep(@will_interval_0_0_1)
        rescue IO::EAGAINWaitReadable
        end
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
        raise ProConRejected.new(e)
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
        ProconBypassMan.logger(">>> #{input.b}")
        @procon.write_nonblock(input)
        if input[0] == "\x80".b && input[1] == "\x01".b
          ProconBypassMan.logger("first negotiation is over")
          break
        end
      rescue IO::EAGAINWaitReadable
      end
    end
  end
end

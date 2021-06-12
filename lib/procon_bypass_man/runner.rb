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

    Thread.new do
      loop do
        input = nil
        begin
          input = @gadget.read_nonblock(128)
        rescue IO::EAGAINWaitReadable
          sleep(0.1)
          retry
        end

        begin
          ProconBypassMan.logger(">>> #{output.b}")
          @procon.write_nonblock(input)
          sleep(0.0)
          sleep(@will_interval_1_6)
        rescue IO::EAGAINWaitReadable
          sleep(@will_interval_1_6)
        end
      rescue Errno::EIO, Errno::ENODEV, Errno::EPROTO, IOError => e
        raise ProConRejected.new(e)
      end
    end

    Thread.new do
      loop do
        output = nil
        begin
          output = @procon.read_nonblock(128)
        rescue IO::EAGAINWaitReadable
          sleep(0.0)
          retry
        end
        begin
          ProconBypassMan.logger("<<< #{output.b}")
          @gadget.write_nonblock(
            ProconBypassMan::Processor.new(output).process
          )
          sleep(@will_interval_0_0_1)
        rescue IO::EAGAINWaitReadable
          sleep(0.0)
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
        ProconBypassMan.logger(">>> #{output.b}")
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

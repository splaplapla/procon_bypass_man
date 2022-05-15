class ProconBypassMan::DeviceConnection::OutputReportGenerator
  SUPPORT_STEPS = {
    home_led_on: "3801",
  }

  def initialize
    @counter = 0
  end

  def generate_by_step(step)
    sub_command_with_arg = SUPPORT_STEPS[step] or raise("Unsupport step")
    raw_data = [
      ["01", counter, "00" * 8, sub_command_with_arg].join
    ].pack("H*")
    count_up
    raw_data
  end

  def generate_by_sub_command_with_arg(sub_command_with_arg)
    raw_data = [
      ["01", counter, "00" * 8, sub_command_with_arg].join
    ].pack("H*")
    count_up
    raw_data
  end

  private

  def count_up
    @counter = @counter + 1
    if @counter >= 256
      @counter = 0
    else
      @counter
    end
  end

  def counter
    @counter.to_s(16).rjust(2, "0")
  end
end

class ProconBypassMan::DeviceConnection::OutputReportGenerator
  SUPPORT_STEPS = {
    home_led_on: "381FF0FF",
  }

  def initialize
    @counter = 0
  end

  # @return [String]
  def generate_by_step(step)
    sub_command_with_arg = SUPPORT_STEPS[step] or raise("Unsupport step")
    raw_data = generate(sub_command_with_arg)
    count_up
    raw_data
  end

  # @return [String]
  def generate_by_sub_command_with_arg(sub_command_with_arg)
    raw_data = generate(sub_command_with_arg)
    count_up
    raw_data
  end

  private

  # @return [String]
  def generate(sub_command_with_arg)
    [
      ["01", counter, "00" * 8, sub_command_with_arg].join
    ].pack("H*")
  end

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

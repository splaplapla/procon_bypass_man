class ProconBypassMan::DeviceConnection::OutputReportGenerator
  STEPS = {
    home_led_on: "3801",
  }

  attr_accessor :counter

  def initialize
    self.counter = 0
  end

  # @return [String]
  def generate(step: )
    "01#{counter}00000000000000003801"
    count_up
  end

  private

  def count_up
  end

end

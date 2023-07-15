class OutputReportGenerator
  NO_ACTION = ["30f28100800078c77448287509550274ff131029001b0022005a0271ff191028001e00210064027cff1410280020002100000000000000000000000000000000"].pack("H*")

  # @param [Array<Symbol, String>, NilClass] pressed_buttons
  def initialize(*pressed_buttons)
    @buttons = pressed_buttons || []
  end

  # @return [String]
  def execute
    user_operation = ProconBypassMan::Procon::UserOperation.new(NO_ACTION.dup)
    [@buttons].flatten.sort.uniq.each do |button|
      user_operation.press_button(button.to_sym)
    end

    user_operation.binary.unpack.first
  end
end

class ProconBypassMan::Procon
  ProconBypassMan::Procon::ButtonCollection.available.each do |button|
    method_name = "pressed_#{button}?"
    define_method(method_name) do
      user_operation.public_send(method_name)
    end
  end

  # @return [Array<Symbol>]
  def pressing
    ProconBypassMan::ProconReader.new(binary: user_operation.binary.binary).pressing
  end
end

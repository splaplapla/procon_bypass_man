class ProconBypassMan::Procon
  # @return [Array<Symbol>]
  def pressing
    ProconBypassMan::ProconReader.new(binary: to_binary).pressing
  end

  private

  # TODO: methods.grepで調べられないのでdefine_methodで定義したい
  def method_missing(name)
    if name.to_s =~ /\Apressed_[a-z]+\?\z/
      user_operation.public_send(name)
    else
      super
    end
  end
end

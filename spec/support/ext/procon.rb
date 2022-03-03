class ProconBypassMan::Procon
  private

  def method_missing(name)
    if name.to_s =~ /\Apressed_[a-z]+\?\z/
      user_operation.public_send(name)
    else
      super
    end
  end
end

module ProconBypassMan::Domains::HasImmutableBinary
  def binary
    @binary.freeze
  end
end

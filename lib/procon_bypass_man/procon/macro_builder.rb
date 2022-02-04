class ProconBypassMan::Procon::MacroBuilder
  def initialize(steps)
    @steps = steps
  end

  def build
    ProconBypassMan::Procon::ButtonCollection.normalize(@steps)
  end
end

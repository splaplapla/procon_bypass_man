class ProconBypassMan::Layer
  attr_accessor :mode

  def initialize(mode: :normal, &block)
    self.mode = mode
    instance_eval(&block) if block_given?
  end

  # @param [Array] buttons
  def flip(buttons)
    @flip = buttons
  end

  # @return [Array]
  def flip_buttons
    @flip || []
  end
end

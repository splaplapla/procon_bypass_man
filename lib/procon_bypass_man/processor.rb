module ProconBypassMan
  module Processor
    # @return [String] binary
    def initialize(binary)
      @binary = binary
    end

    # @return [String]
    def process
      @binary
    end
  end
end

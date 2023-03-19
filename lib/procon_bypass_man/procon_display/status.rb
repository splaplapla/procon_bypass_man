class ProconBypassMan::ProconDisplay::Status
  include Singleton

  # @return [Hash]
  def current
    @current || {}
  end

  # @return [void]
  # @param [Hash] value
  # NOTE: valueには参照が入ってくるので変更する時はdupすること
  def current=(value)
    if value.is_a?(Hash)
      @current = value
    else
      @current = nil
    end
  end
end

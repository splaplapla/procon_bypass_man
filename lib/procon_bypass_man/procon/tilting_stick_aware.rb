class ProconBypassMan::TiltingStickAware
  def self.tilting?(result)
    if (-200..200).include?(result[:min][:x]) && (-200..200).include?(result[:min][:y])
      return false
    end

    result[:power] > 500
  end
end

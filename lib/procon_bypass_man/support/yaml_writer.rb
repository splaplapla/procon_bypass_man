class ProconBypassMan::YamlWriter
  # @return [void]
  def self.write(path: , content: )
    File.write(
      path,
      content.transform_values { |x|
        case x
        when String
          x.gsub("\r\n", "\n")
        else
          x
        end
      }.to_yaml
    )
  end
end

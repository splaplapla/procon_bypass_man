class ProconBypassMan::YamlWriter
  # @return [void]
  def self.write(path: , content: )
    File.write(
      path,
      content.gsub("\r\n", "\n").to_yaml,
    )
  end
end

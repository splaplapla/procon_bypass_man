class ProconBypassMan::YamlLoader
  # @param [String] path
  # @return [Hash]
  def self.load(path: )
    YAML.load_file(path).tap do |y|
      # 行末に空白があるとto_yamlしたときに改行コードがエスケープされてしまうのでstrip
      y.transform_values do |v|
        v.strip! if v.is_a?(String)
      end
    end
  end
end

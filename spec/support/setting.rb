require "tempfile"

class Setting
  def initialize(content)
    @content = content
  end

  # @return [File]
  def to_file
    file = Tempfile.new(["", ".yml"])
    file.write @content
    file.seek 0
    file
  end
end

class ProconBypassMan::BootMessage
  def initialize
    @h = {}
    @h[:RUBY_VERSION] = RUBY_VERSION
    @h[:ProconBypassMan] = ProconBypassMan::VERSION
    @h[:pid] = $$
    @h[:root_path] = ProconBypassMan.root
    @h[:pid_path] = ProconBypassMan.pid_path
    @h[:setting_path] = ProconBypassMan::Configuration.instance.setting_path
    @h[:uptime_from_boot] = { type: :value, value: ProconBypassMan::Uptime.from_boot, suffix: " sec" }
  end

  # @return [String]
  def to_s
    @h.each do
      # TODO hashを変換する
    end
  end

  # @return [Hash]
  def to_hash
    @h.each do
      # TODO hashを変換する
    end
  end
end

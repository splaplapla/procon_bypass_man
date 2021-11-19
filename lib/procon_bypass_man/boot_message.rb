class ProconBypassMan::BootMessage
  def initialize
    @table = {}
    @table[:ruby_version] = RUBY_VERSION
    @table[:pbm_version] = ProconBypassMan::VERSION
    @table[:pid] = $$
    @table[:root_path] = ProconBypassMan.root
    @table[:pid_path] = ProconBypassMan.pid_path
    @table[:setting_path] = ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path
    @table[:uptime_from_boot] = ProconBypassMan::Uptime.from_boot
    @table[:use_pbmenv] = !(!!`which pbmenv`.empty?)

    # 開発中のHEADを取りたかったけど、Gem::Specification経由から取得する必要がありそう
    # build_version = `git rev-parse --short HEAD`.chomp
    # if build_version.empty?
    #   @table[:build_version] = 'release version'
    # else
    #   @table[:build_version] = build_version
    # end

    # build version: #{@table[:build_version]}
  end

  # @return [String]
  def to_s
    booted_message = <<~EOF
      ----
      RUBY_VERSION: #{@table[:ruby_version]}
      ProconBypassMan: #{@table[:pbm_version]}
      pid: #{@table[:pid]}
      root: #{@table[:root_path]}
      pid_path: #{@table[:pid_path]}
      setting_path: #{@table[:setting_path]}
      uptime from boot: #{@table[:uptime_from_boot]} sec
      use_pbmenv: #{@table[:use_pbmenv]}
      ----
    EOF
  end

  # @return [Hash]
  def to_hash
    @table
  end
end

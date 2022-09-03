class ProconBypassMan::PrintBootMessageCommand
  class BootMessage
    def initialize
      @table = {}
      @table[:ruby_version] = RUBY_VERSION
      @table[:pbm_version] = ProconBypassMan::VERSION
      @table[:pbmenv_version] = Pbmenv::VERSION
      @table[:pid] = $$
      @table[:root_path] = ProconBypassMan.root
      @table[:pid_path] = ProconBypassMan.pid_path
      @table[:setting_path] = ProconBypassMan::ButtonsSettingConfiguration.instance.setting_path
      @table[:uptime_from_boot] = ProconBypassMan::Uptime.from_boot
      @table[:use_pbmenv] = !(!!`which pbmenv`.empty?)
      @table[:session_id] = ProconBypassMan.session_id
      @table[:device_id] = ProconBypassMan.device_id
      @table[:never_exit_accidentally] = ProconBypassMan.config.never_exit_accidentally
      @table[:uname] = `uname -a`.chomp

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
      ProconBypassMan::VERSION: #{@table[:pbm_version]}
      RUBY_VERSION: #{@table[:ruby_version]}
      Pbmenv::VERSION: #{@table[:pbmenv_version]}
      pid: #{@table[:pid]}
      root: #{@table[:root_path]}
      pid_path: #{@table[:pid_path]}
      setting_path: #{@table[:setting_path]}
      uptime from boot: #{@table[:uptime_from_boot]} sec
      use_pbmenv: #{@table[:use_pbmenv]}
      session_id: #{ProconBypassMan.session_id}
      device_id: #{ProconBypassMan.device_id.gsub(/.{25}$/, "*"*25)}
      ----
      EOF
    end

    # @return [Hash]
    def to_hash
      @table
    end
  end

  # @return [void]
  def self.execute
    message = BootMessage.new
    ProconBypassMan::ReportBootJob.perform_async(message.to_hash)
    puts message.to_s
  end
end

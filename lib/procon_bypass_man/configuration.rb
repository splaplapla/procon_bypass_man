class ProconBypassMan::Configuration
  module ClassMethods
    def root
      config.root
    end

    def logger
      config.logger
    end

    def error_logger
      config.error_logger
    end

    def pid_path
      @@pid_path ||= File.expand_path("#{root}/pbm_pid", __dir__).freeze
    end

    # @return [Integer]
    def pid
      File.read(pid_path).to_i
    end

    def digest_path
      config.digest_path
    end

    def cache
      @@cache_table ||= ProconBypassMan::OnMemoryCache.new
    end

    # @return [String]
    def session_id
      ProconBypassMan::WriteSessionIdCommand.execute
    end

    # @return [String]
    def device_id
      ENV["DEBUG_DEVICE_ID"] || ProconBypassMan::WriteDeviceIdCommand.execute
    end
  end

  attr_accessor :enable_critical_error_logging
  attr_writer :verbose_bypass_log, :raw_setting, :enable_reporting_pressed_buttons

  def root=(path)
    @root = path
    return self
  end

  def root
    if defined?(@root)
      @root
    else
      File.expand_path('..', __dir__ || ".").freeze
    end
  end

  def api_servers=(api_servers)
    @api_servers = api_servers
    return self
  end

  def logger=(logger)
    @logger = logger
    return self
  end

  def logger
    if ENV["PBM_ENV"] == 'test'
      return Logger.new($stdout)
    end

    if defined?(@logger) && @logger.is_a?(Logger)
      @logger
    else
      Logger.new(File.open("/dev/null"))
    end
  end

  def error_logger
    if enable_critical_error_logging
      @error_logger ||= Logger.new("#{ProconBypassMan.root}/error.log", 5, 1024 * 1024 * 10)
    else
      Logger.new(File.open("/dev/null"))
    end
  end

  def digest_path
    "#{root}/.setting_yaml_digest"
  end

  # @return [String] pbm-webの接続先
  def internal_api_servers
    if !!ENV["INTERNAL_API_SERVER"]
      [ENV["INTERNAL_API_SERVER"]]
    else
      [ 'http://localhost:9090',
        'http://localhost:8080',
      ].compact
    end
  end

  # @return [Array<ProconBypassMan::ServerPool>]
  def internal_server_pool
    @internal_server_pool ||= ProconBypassMan::ServerPool.new(servers: internal_api_servers)
  end

  # @return [Array<ProconBypassMan::ServerPool>]
  def server_pool
    @server_pool ||= ProconBypassMan::ServerPool.new(servers: api_servers)
  end

  # @return [String, NilClass]
  def current_server
    server_pool.server
  end

  # @return [String, NilClass]
  def current_ws_server
    if (uri = URI.parse(server_pool.server))
      if uri.port == 443
        return "ws://#{uri.host}"
      else
        return "ws://#{uri.host}:#{uri.port}"
      end
    end
  rescue URI::InvalidURIError
    nil
  end

  # @return [String, NilClass]
  def current_ws_server_url
    return unless current_ws_server
    "#{current_ws_server}/websocket/"
  end

  # @return [Boolean]
  def enable_ws?
    !!current_server
  end

  # @return [Boolean]
  def enable_remote_macro?
    enable_ws?
  end

  # @return [Array<String>]
  def api_servers
    if !!ENV["API_SERVER"]
      [ENV["API_SERVER"]].reject(&:nil?)
    else
      [@api_servers].flatten.reject(&:nil?)
    end
  end

  def verbose_bypass_log
    @verbose_bypass_log || !!ENV["VERBOSE_BYPASS_LOG"]
  end

  def raw_setting
    @raw_setting ||= {}
  end

  def enable_reporting_pressed_buttons
    @enable_reporting_pressed_buttons ||= false
  end
end

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

    def digest_path
      config.digest_path
    end

    def cache
      @@cache_table ||= ProconBypassMan::OnMemoryCache.new
    end
  end

  attr_accessor :enable_critical_error_logging

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

  # @deprecated
  def api_server=(api_server)
    @api_server = api_server
    return self
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
      @@error_logger ||= Logger.new("#{ProconBypassMan.root}/error.log", 5, 1024 * 1024 * 10)
    else
      Logger.new(File.open("/dev/null"))
    end
    self
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

  def api_servers
    if !!ENV["API_SERVER"]
      [ENV["API_SERVER"]]
    else
      [@api_servers].flatten
    end
  end

  def verbose_bypass_log=(value)
    @verbose_bypass_log = value
  end

  def verbose_bypass_log
    @verbose_bypass_log || !!ENV["VERBOSE_BYPASS_LOG"]
  end
end

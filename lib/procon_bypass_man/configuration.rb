# frozen_string_literal: true

# app.rbから設定される値。プロセスを起動してから不変
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

    # @return [Integer, nil]
    def pid
      File.read(pid_path).to_i
    rescue Errno::ENOENT
      nil
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

    # @return [Boolean]
    def never_exit_accidentally
      config.never_exit_accidentally
    end

    def fallback_setting_path
      "/tmp/procon_bypass_man_fallback_setting.yaml"
    end
  end

  attr_accessor :enable_critical_error_logging
  attr_writer :verbose_bypass_log, :raw_setting, :never_exit_accidentally, :enable_home_led_on_connect
  attr_writer :external_input_channels
  # 削除予定
  attr_writer :enable_reporting_pressed_buttons

  # NOTE 非推奨. 削除したいが設定ファイルに残っているときにエラーにしたくないので互換性維持のため残す
  attr_writer :io_monitor_logging

  def root=(path)
    @root = path
    return self
  end

  def root
    if defined?(@root)
      @root
    else
      ProconBypassMan.logger.warn 'root pathが未設定です'
      File.expand_path('..', __dir__ || ".").freeze
    end
  end

  # NOTE 不具合の原因は修正済みなので可変である必要は無くなった。削除したいが各端末内の設定ファイルに存在している場合があるのでしばらく残す
  def bypass_mode=(value)
    @bypass_mode = ProconBypassMan::BypassMode.new(
      mode: value[:mode],
      gadget_to_procon_interval: value[:gadget_to_procon_interval],
    )
  end

  def bypass_mode
    @bypass_mode || ProconBypassMan::BypassMode.default_value
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
      @error_logger ||= Logger.new("#{ProconBypassMan.root}/error.log", 1, 1024 * 1024 * 1)
    else
      Logger.new(File.open("/dev/null"))
    end
  end

  def digest_path
    "#{root}/.setting_yaml_digest"
  end

  # @return [String, NilClass]
  def api_server
    api_servers&.first
  end

  # @return [String, NilClass]
  def current_ws_server_url
    return @current_ws_server_url if defined?(@current_ws_server_url)
    return unless api_server

    response_json = ProconBypassMan::HttpClient.new(server: api_server, path: '/api/v1/configuration').get
    ws_server_url = response_json&.fetch("ws_server_url", nil)

    begin
      uri = URI.parse(ws_server_url)
      if uri.scheme == 'ws' or uri.scheme == 'wss'
        @current_ws_server_url = uri.to_s
        return @current_ws_server_url
      else
        ProconBypassMan.logger.warn { "#{ws_server_url} is invalid." }
        return nil
      end
    rescue URI::InvalidURIError => e
      ProconBypassMan.logger.warn { "#{ws_server_url} is invalid. #{e}" }
      nil
    end
  end

  # @return [Boolean]
  def enable_ws?
    !!api_server
  end

  # @return [Boolean]
  def enable_remote_action?
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

  # @return [Boolean]
  def has_api_server?
    !!api_server
  end

  def verbose_bypass_log
    @verbose_bypass_log || !!ENV["VERBOSE_BYPASS_LOG"]
  end

  def raw_setting
    @raw_setting ||= {}
  end

  # @return [Boolean] default false
  def never_exit_accidentally
    @never_exit_accidentally || false
  end

  # @return [Boolean] プロコンから「入力にかかっている時間」と「1秒間あたり何回入力できているか」をサーバに送信する
  def enable_procon_performance_measurement?
    has_api_server?
  end

  # @return [Boolean] default true
  def enable_home_led_on_connect
    if defined?(@enable_home_led_on_connect)
      return @enable_home_led_on_connect
    else
      true
    end
  end

  # @return [Array<ProconBypassMan::ExternalInput::Channel::TCPIP, ProconBypassMan::ExternalInput::Channel::SerialPort>]
  def external_input_channels
    @external_input_channels || []
  end
end

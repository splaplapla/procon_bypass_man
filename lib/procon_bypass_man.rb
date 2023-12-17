# frozen_string_literal: true

require 'singleton'
require "logger"
require 'yaml'
require "json"
require "net/http"
require "fileutils"
require "securerandom"
require 'em/pure_ruby'
require "action_cable_client"
require "ext/em_pure_ruby"
require "ext/module"
require "resolv-replace"
require "pbmenv"
require "blue_green_process"

require_relative "procon_bypass_man/version"

require_relative "procon_bypass_man/device_connection"
require_relative "procon_bypass_man/support/usb_device_controller"
require_relative "procon_bypass_man/support/device_procon_finder"
require_relative "procon_bypass_man/support/device_mouse_finder"
require_relative "procon_bypass_man/support/callbacks"
require_relative "procon_bypass_man/support/yaml_loader"
require_relative "procon_bypass_man/support/yaml_writer"
require_relative "procon_bypass_man/support/safe_timeout"
require_relative "procon_bypass_man/support/compress_array"
require_relative "procon_bypass_man/support/uptime"
require_relative "procon_bypass_man/support/load_agv"
require_relative "procon_bypass_man/support/on_memory_cache"
require_relative "procon_bypass_man/support/http_client"
require_relative "procon_bypass_man/support/report_http_client"
require_relative "procon_bypass_man/support/remote_macro_http_client"
require_relative "procon_bypass_man/support/update_remote_pbm_job_status_http_client"
require_relative "procon_bypass_man/support/send_device_stats_http_client"
require_relative "procon_bypass_man/support/procon_performance_http_client"
require_relative "procon_bypass_man/support/analog_stick_hypotenuse_tilting_power_scaler"
require_relative "procon_bypass_man/support/never_exit_accidentally"
require_relative "procon_bypass_man/support/cycle_sleep"
require_relative "procon_bypass_man/support/can_over_process"
require_relative "procon_bypass_man/support/retryable"
require_relative "procon_bypass_man/support/renice_command"
require_relative "procon_bypass_man/support/web_connectivity_checker"
require_relative "procon_bypass_man/support/watchdog"
require_relative "procon_bypass_man/support/forever"
require_relative "procon_bypass_man/support/simple_tcp_server"
require_relative "procon_bypass_man/support/proccess_cheacker"
require_relative "procon_bypass_man/support/output_report_generator"
require_relative "procon_bypass_man/support/sudo_need_password_checker"
require_relative "procon_bypass_man/support/shell_runner"
require_relative "procon_bypass_man/procon_display"
require_relative "procon_bypass_man/background"
require_relative "procon_bypass_man/commands"
require_relative "procon_bypass_man/bypass"
require_relative "procon_bypass_man/device_status"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/configuration"
require_relative "procon_bypass_man/ephemeral_configuration"
require_relative "procon_bypass_man/buttons_setting_configuration"
require_relative "procon_bypass_man/procon"
require_relative "procon_bypass_man/device_model"
require_relative "procon_bypass_man/procon/button"
require_relative "procon_bypass_man/procon/analog_stick_cap"
require_relative "procon_bypass_man/procon/analog_stick_manipulator"
require_relative "procon_bypass_man/scheduler"
require_relative "procon_bypass_man/plugins"
require_relative "procon_bypass_man/worker"
require_relative "procon_bypass_man/websocket/client"
require_relative "procon_bypass_man/external_input"
require_relative "procon_bypass_man/remote_action"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  extend ProconBypassMan::Configuration::ClassMethods

  class CouldNotLoadConfigError < StandardError; end
  class NotFoundProconError < StandardError; end

  class InterruptForRestart < StandardError; end

  class << self
    attr_accessor :worker
  end

  # @return [void]
  def self.run(setting_path: nil)
    ProconBypassMan::PrintMessageCommand.execute(text: "PBMを起動しています")
    initialize_pbm

    # 設定ファイルの読み込み
    begin
      ProconBypassMan::ButtonsSettingConfiguration::Loader.load(setting_path: setting_path)
    rescue ProconBypassMan::CouldNotLoadConfigError
      ProconBypassMan::SendErrorCommand.execute(error: "設定ファイルが不正です。設定ファイルの読み込みに失敗しました")
      ProconBypassMan::DeviceStatus.change_to_setting_syntax_error_and_shutdown!
      # TODO シグナルトラップをしていないのでUSR2を送ったときにプロセスが停止している. 明示的にハンドリングするべき.
      ProconBypassMan::NeverExitAccidentally.exit_if_allow_at_config do
        terminate_pbm
      end
      return
    end

    # デバイスの接続フェーズ
    begin
      gadget, procon = ProconBypassMan::DeviceConnection::Command.execute!
    rescue ProconBypassMan::DeviceConnection::SetupIncompleteError
      ProconBypassMan::SendErrorCommand.execute(error: "The program is terminating because it encountered a request for the sudo password. Please review your sudo settings.", stdout: true)
      ProconBypassMan::DeviceStatus.change_to_procon_not_found_error! # NOTE: procon_not_found_errorではないけど、めんどいのでこのステータスにする
      ProconBypassMan::NeverExitAccidentally.exit_if_allow_at_config do
        terminate_pbm
      end
      return
    rescue ProconBypassMan::DeviceConnection::NotFoundProconError
      ProconBypassMan::SendErrorCommand.execute(error: "プロコンが見つかりませんでした。")
      ProconBypassMan::DeviceStatus.change_to_procon_not_found_error!
      # TODO シグナルトラップをしていないので以下の状態に、USR2を送ったときにプロセスが停止してしまう
      ProconBypassMan::NeverExitAccidentally.exit_if_allow_at_config do
        terminate_pbm
      end
      return
    rescue ProconBypassMan::DeviceConnection::TimeoutError
      ProconBypassMan::SendErrorCommand.execute(error: "接続に失敗しました。プロコンとRaspberry Piのケーブルを差し直して、再実行してください。\n改善しない場合は、app.logの中身を添えて不具合報告をお願いします。")
      ProconBypassMan::DeviceStatus.change_to_connected_but_sleeping!
      FileUtils.rm_rf(ProconBypassMan.pid_path) # NOTE: この状態になったときに手動で起動できるようにする(多重起動禁止回避)

      %w(TERM INT).each do |sig|
        Kernel.trap(sig) { exit 0 }
      end
      Kernel.trap :USR2 do
        exit 0 # TODO retryする
      end
      eternal_sleep
      return
    end

    ready_pbm
    Runner.new(gadget: gadget, procon: procon).run # ここでblockingする
    terminate_pbm
  end

  # 実行ファイル(app.rb)から呼び出している
  # @return [void]
  def self.configure(&block)
    require_relative "procon_bypass_man/external_input"

    @@configuration = ProconBypassMan::Configuration.new
    @@configuration.instance_eval(&block)
    nil
  end

  # @return [ProconBypassMan::Configuration]
  def self.config
    @@configuration ||= ProconBypassMan::Configuration.new
  end

  # @return [ProconBypassMan::EphemeralConfiguration]
  def self.ephemeral_config
    @@ephemeral_configuration ||= ProconBypassMan::EphemeralConfiguration.new
  end

  # @return [void]
  def self.reset!
    ProconBypassMan::Procon::MacroRegistry.reset!
    ProconBypassMan::Procon::ModeRegistry.reset!
    ProconBypassMan::Procon.reset!
    ProconBypassMan::ButtonsSettingConfiguration.instance.reset!
  end

  # @return [void]
  def self.initialize_pbm
    if ProconBypassMan.pid && ProconBypassMan::ProcessChecker.running?(ProconBypassMan.pid)
      ProconBypassMan::SendErrorCommand.execute(error: "別のプロセスでPBMがすでに起動中なので処理を停止します。")
      raise 'テスト実行中でここに入ると調査が面倒なのでエラーにします' if ENV['PBM_ENV'] == 'test'
      exit 1
    end

    ProconBypassMan::ReniceCommand.change_priority(to: :low, pid: $$)
    ProconBypassMan::Background::JobQueue.start!
    ProconBypassMan::Websocket::Client.start!
    # TODO ProconBypassMan::DrbObjects.start_all! みたいな感じで書きたい
    ProconBypassMan::RemoteAction::QueueOverProcess.start!
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.start!
    ProconBypassMan::Scheduler.start!

    ProconBypassMan::WriteDeviceIdCommand.execute
    ProconBypassMan::WriteSessionIdCommand.execute
    File.write(pid_path, $$)
    ProconBypassMan::DeviceStatus.change_to_running!
  end

  # @return [void]
  def self.ready_pbm
    ProconBypassMan::PrintBootMessageCommand.execute
    ProconBypassMan::ReportLoadConfigJob.perform_async(ProconBypassMan.config.raw_setting)

    self.worker = ProconBypassMan::Worker.run
  end

  # @return [void]
  def self.run_on_after_fork_of_bypass_process
    ProconBypassMan::ReniceCommand.change_priority(to: :high, pid: $$)
    ::GC.start
    # GC対策することによって一時的に削除した機能. 後で有効にしたい
    # ProconBypassMan::ProconDisplay::Server.start!
    DRb.start_service if defined?(DRb)

    # for libs setting
    BlueGreenProcess.config.logger = ProconBypassMan.logger

    BlueGreenProcess.configure do |config|
      config.after_fork = -> {
        DRb.start_service if defined?(DRb)
        ProconBypassMan::RemoteActionReceiver.start!
        BlueGreenProcess.config.logger = ProconBypassMan.logger
      }
      config.shared_variables = [:buttons, :current_layer_key, :recent_left_stick_hypotenuses]
    end
  end

  # @return [void]
  def self.terminate_pbm
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    FileUtils.rm_rf(ProconBypassMan.digest_path)
    ProconBypassMan::RemoteAction::QueueOverProcess.shutdown
    ProconBypassMan::Procon::PerformanceMeasurement::QueueOverProcess.shutdown
    self.worker&.shutdown
    ProconBypassMan::ExternalInput.shutdown
  end

  # @return [void]
  def self.eternal_sleep
    sleep(999999999)
  end
end

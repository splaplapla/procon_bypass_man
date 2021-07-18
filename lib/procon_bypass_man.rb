require "logger"
require 'yaml'
require "fileutils"

require_relative "procon_bypass_man/version"
require_relative "procon_bypass_man/device_registry"
require_relative "procon_bypass_man/bypass"
require_relative "procon_bypass_man/runner"
require_relative "procon_bypass_man/processor"
require_relative "procon_bypass_man/configuration"
require_relative "procon_bypass_man/procon"

STDOUT.sync = true
Thread.abort_on_exception = true

module ProconBypassMan
  class ProConRejected < StandardError; end
  class CouldNotLoadConfigError < StandardError; end
  class FirstConnectionError < StandardError; end

  def self.configure(setting_path: nil, &block)
    unless setting_path
      logger.warn "setting_pathが未設定です。設定ファイルのライブリロードが使えません。"
    end

    if block_given?
      ProconBypassMan::Configuration.instance.instance_eval(&block)
    else
      ProconBypassMan::Configuration::Loader.load(setting_path: setting_path)
    end
  end

  def self.run(setting_path: nil, &block)
    configure(setting_path: setting_path, &block)
    File.write(pid_path, $$)
    registry = ProconBypassMan::DeviceRegistry.new
    Runner.new(gadget: registry.gadget, procon: registry.procon).run
  rescue CouldNotLoadConfigError
    ProconBypassMan.logger.error "設定ファイルが不正です。設定ファイルの読み込みに失敗しました"
    puts "設定ファイルが不正です。設定ファイルの読み込みに失敗しました"
    FileUtils.rm_rf(ProconBypassMan.pid_path)
    exit 1
  rescue FirstConnectionError
    puts "接続を確立できませんでした。やりなおします。"
    retry
  end

  def self.logger=(logger)
    @@logger = logger
  end

  def self.logger
    if defined?(@@logger)
      @@logger
    else
      Logger.new(nil)
    end
  end

  def self.pid_path
    @@pid_path ||= File.expand_path("#{root}/pbm_pid", __dir__).freeze
  end

  def self.reset!
    ProconBypassMan::Procon::MacroRegistry.reset!
    ProconBypassMan::Procon::ModeRegistry.reset!
    ProconBypassMan::Procon.reset!
    ProconBypassMan::Configuration.instance.reset!
    ProconBypassMan::IOMonitor.reset!
  end

  def self.root
    if defined?(@@root)
      @@root
    else
      File.expand_path('..', __dir__).freeze
    end
  end

  def self.root=(path)
    @@root = path
  end

  # bundle install相当の処理中にプロセスが死ぬとファイルの整合性が取れなくて死に続ける問題への対策
  # 原文ママ: <Bundler::Source::Git::GitCommandError: Git error: command `git fetch --force --quiet --tags https://github.com/splaspla-hacker/procon_bypass_man-web refs/heads/\*:refs/heads/\*` in directory /home/pi/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/cache/bundler/git/procon_bypass_man-web-684bff71720a35ca5928a1af9f6458aff01a8fd1 has failed. If this error persists you could try removing the cache directory '/home/pi/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/cache/bundler/git/procon_bypass_man-web-684bff71720a35ca5928a1af9f6458aff01a8fd1'>
  def self.remove_bundler_cache_if_need(&block)
    begin
      block.call
    # TODO  bundlerのバージョンを指定する
    rescue Bundler::Source::Git::GitCommandError => e
      if %r!If this error persists you could try removing the cache directory '([^']+)'! =~ e.to_s
        if is_correct_directory_to_remove?($1)
          FileUtiles.rm_rf($1)
          puts "Bundler::Source::Git::GitCommandErrorが起きたので問題のディレクトリを削除しました。"
        else
          raise "bundlerのキャッシュディレクトリを削除できませんでした"
        end
      end
      retry
    end
  end

  def self.is_correct_directory_to_remove?(dir)
    !!(%r!^/home/pi/.rbenv/versions/! =~ dir)
  end
end

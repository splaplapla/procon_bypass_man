# frozen_string_literal: true

module ProconBypassMan
  module ExternalInput
    class ParseError < StandardError; end

    @@channels = nil

    # @return [Array<ProconBypassMan::ExternalInput::Channel>]
    def self.channels
      @@channels
    end

    # @return [void]
    def self.prepare_channels
      @@channels = ProconBypassMan.config.external_input_channels.map { |external_input_channel|
        ProconBypassMan::ExternalInput::Channel.new(external_input_channel)
      }
    end

    # @return [NilClass, String]
    def self.read
      raise '外部入力が見初期化です' if @@channels.nil? # NOTE: エラーにした方がいいかも

      # ProconBypassMan.config.external_input_channels.map(&:read_nonblock)
      @@channels.map(&:read).reject(&:nil?).first
    end
  end
end

require "procon_bypass_man/external_input/external_data"
require "procon_bypass_man/external_input/channels.rb"

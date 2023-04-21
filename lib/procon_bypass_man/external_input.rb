# frozen_string_literal: true

module ProconBypassMan
  module ExternalInput
    class ParseError < StandardError; end

    # @return [Array<ProconBypassMan::ExternalInput::Channels::Base>]
    def self.channels
      @@channels ||= ProconBypassMan.config.external_input_channels
    end

    def self.shutdown
      channels.each(&:shutdown)
    end

    # @return [NilClass, String]
    # NOTE: 外部入力からのreadがボトルネックになるなら、Concurrent::Futureを使ってプロコンからの読み出しと並列化することを検討する
    def self.read
      value = nil
      channels.each do |channel|
        value = channel.read
        break if value
      end
      value
    end
  end
end

require "procon_bypass_man/external_input/external_data"
require "procon_bypass_man/external_input/channels.rb"

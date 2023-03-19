# frozen_string_literal: true

module ProconBypassMan
  module ExternalInput
    class ParseError < StandardError; end
  end
end

require "procon_bypass_man/external_input/external_data"
require "procon_bypass_man/external_input/channels.rb"

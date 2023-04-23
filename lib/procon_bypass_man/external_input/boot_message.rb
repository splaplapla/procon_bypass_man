# frozen_string_literal: true

module ProconBypassMan
  module ExternalInput
    class BootMessage
      # @return [ProconBypassMan::ExternalInput::Channels::Base]
      def initialize(channels: )
        @channels = channels
      end

      # @return [String]
      def to_s
        if @channels.nil? or @channels.empty?
          return 'DISABLE'
        end

        @channels.map(&:display_name_for_boot_message).join(', ')
      end
    end
  end
end

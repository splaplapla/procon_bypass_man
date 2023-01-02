module ProconBypassMan
  class ButtonsSettingConfiguration
    class MetadataLoader
      EMPTY_VERSION = '0.0.0'

      # @param [String] setting_path
      # @return [MetadataLoader]
      def self.load(setting_path: )
        self.new(setting_path)
      end

      # @param [String] setting_path
      def initialize(setting_path)
        content = File.read(setting_path)
        if(matched = content.match(/metadata-required_pbm_version: ([\d.]+)/))
          @required_pbm_version = matched[1]
        end
      end

      # @return [String]
      def required_pbm_version
        return EMPTY_VERSION unless defined?(@required_pbm_version)
        return @required_pbm_version if @required_pbm_version
      end
    end
  end
end

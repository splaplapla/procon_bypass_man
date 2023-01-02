require "spec_helper"

describe ProconBypassMan::ButtonsSettingConfiguration::MetadataLoader do
  let(:setting) { Setting.new(setting_content).to_file }

  describe '#required_pbm_version' do
    context 'metadataの記載がない' do
      let(:setting_content) do
        <<~EOH
          version: 1.0
          setting: |
            prefix_keys_for_changing_layer [:zr, :zl, :l]
        EOH
      end

      it 'empty valueを返す' do
        loader = described_class.load(setting_path: setting.path)
        expect(loader.required_pbm_version).to eq('0.0.0')
      end
    end

    context 'metadata required_pbm_versionの記載がある' do
      let(:setting_content) do
        <<~EOH
            version: 1.0
            setting: |
              # metadata-required_pbm_version: 0.3.0
              prefix_keys_for_changing_layer [:zr, :zl, :l]
        EOH
      end

      it 'コメントから読み込む' do
        loader = described_class.load(setting_path: setting.path)
        expect(loader.required_pbm_version).to eq('0.3.0')
      end
    end
  end
end

require "spec_helper"

describe ProconBypassMan::YamlWriter do
  describe '#write' do
    let(:file) { Tempfile.new }
    context '\r\nを使っているとき' do
      it '改行コードとして出力すること' do
        described_class.write(path: file.path, content: { a: "a\r\nb" })
        file.rewind
        yaml = file.read
        expect(yaml.split(/\R/).size).to eq(4)
      end
    end

    context '\nを使っているとき' do
      it '改行コードとして出力すること' do
        described_class.write(path: file.path, content: { a: "a\nb" })
        file.rewind
        yaml = file.read
        expect(yaml.split(/\R/).size).to eq(4)
      end
    end

    context 'それっぽいデータ' do
      it '改行コードとして出力すること' do
        content = {"version"=>1.0, "setting"=>"install_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::FastReturn\r\ninstall_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToUpKey\r\ninstall_macro_plugin ProconBypassMan::Plugin::Splatoon2::Macro::JumpToRightKey\r\n"}
        described_class.write(path: file.path, content: content)
        file.rewind
        yaml = file.read
        expect(yaml.split(/\R/).size).to eq(6)
      end
    end
  end
end

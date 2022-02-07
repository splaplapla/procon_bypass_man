require "spec_helper"

describe ProconBypassMan::YamlWriter do
  describe '#write' do
    let(:file) { Tempfile.new }
    context '\r\nを使っているとき' do
      it '改行コードとして出力すること' do
        described_class.write(path: file.path, content: "a\r\nb")
        file.rewind
        yaml = file.read
        expect(yaml.split(/\R/).size).to eq(3)
      end
    end

    context '\nを使っているとき' do
      it '改行コードとして出力すること' do
        described_class.write(path: file.path, content: "a\nb")
        file.rewind
        yaml = file.read
        expect(yaml.split(/\R/).size).to eq(3)
      end
    end
  end
end

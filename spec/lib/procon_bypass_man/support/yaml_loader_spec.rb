require "spec_helper"

describe ProconBypassMan::YamlLoader do
  describe '#load' do
    let(:file) { Tempfile.new(["", ".yaml"]) }
    let(:file_path) { file.path }

    subject { described_class.load(path: file_path) }

    context '行末に空白がない' do
      before do
        file.write({ a: "a\nb" }.to_yaml)
        file.flush
      end

      it do
        expect(subject.to_yaml).to eq("---\n:a: |-\n  a\n  b\n")
      end
    end

    context '行末に空白がある' do
      context do
        before do
          file.write({ a: "a\nb  " }.to_yaml)
          file.flush
        end

        it do
          expect(subject.to_yaml).to eq("---\n:a: |-\n  a\n  b\n")
        end
      end
    end
  end
end

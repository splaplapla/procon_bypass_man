require "spec_helper"

describe ProconBypassMan do
  describe '.logger' do
    it do
      expect(described_class.logger).not_to be_nil
    end
  end

  describe '.is_correct_directory_to_remove?' do
    context '/' do
      it { expect(ProconBypassMan.is_correct_directory_to_remove?("/")).to eq(false) }
    end
    context '/etc' do
      it { expect(ProconBypassMan.is_correct_directory_to_remove?("/etc")).to eq(false) }
    end
    context '/home/hoge' do
      it { expect(ProconBypassMan.is_correct_directory_to_remove?('/home/hoge')).to eq(false) }
    end
    context '/home/pi/.rbenv/versions/3.0.1' do
      it { expect(ProconBypassMan.is_correct_directory_to_remove?('/home/pi/.rbenv/versions/3.0.1')).to eq(true) }
    end
  end
end

require "spec_helper"

describe ProconBypassMan::Bypass::ProconReadThrottling do
  # TODO timeout使わずにしないでテストしたい
  context '1 sec' do
    it do
      counter = 0
      adjuster = described_class.new
      begin
        Timeout.timeout(1) do
          loop do
            adjuster.run do
              counter+= 1
            end
          end
        end
      rescue Timeout::Error
        expect(counter).to eq(72).or eq(73).or eq(74).or eq(75)
      end
    end
  end

  context '2 sec' do
    it do
      counter = 0
      adjuster = described_class.new
      begin
        Timeout.timeout(2) do
          loop do
            adjuster.run do
              counter+= 1
            end
          end
        end
      rescue Timeout::Error
        expect(counter).to eq(142).or eq(143).or eq(144).or eq(145).or eq(146).or eq(147)
      end
    end
  end
end

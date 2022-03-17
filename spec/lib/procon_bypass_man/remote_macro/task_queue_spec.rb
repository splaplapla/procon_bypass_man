require "spec_helper"

describe ProconBypassMan::RemoteMacro::TaskQueue do
  let(:queue) { described_class.new }

  describe '.present?' do
    context 'when blank' do
      it do
        expect(queue.present?).to eq(false)
      end
    end

    context 'when has a task' do
      before do
        queue.push(1)
      end

      it do
        expect(queue.present?).to eq(true)
      end
    end
  end
end

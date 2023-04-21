require "spec_helper"

describe ProconBypassMan::ExternalInput::Channels::TCPIPChannel do
  let(:port) { 9999 }

  describe '.new' do
    it do
      channel = ProconBypassMan::ExternalInput::Channels::TCPIPChannel.new(port: port)

      socket = nil
      ProconBypassMan::Retryable.retryable(tries: 5, on_no_retry: [Errno::ECONNRESET], interval_on_retry: 1) do
        socket = TCPSocket.new('0.0.0.0', port)
      end

      # write
      message = { buttons: [:a] }.to_json + "\n"
      socket.write(message)
      response = socket.gets
      expect(response).to eq("OK\n")

      # read
      message = "\n"
      socket.write(message)
      response = socket.gets
      expect(response).to start_with({ buttons: [:a] }.to_json)

      # read
      message = "\n"
      socket.write(message)
      response = socket.gets # FIXME: \n だけが返ってくるので仕方なく読み出す. これ消したい
      response = socket.gets
      expect(response).to start_with('EMPTY')

      # read
      message = "\n"
      socket.write(message)
      response = socket.gets
      expect(response).to start_with('EMPTY')

      channel.shutdown
      PBMHelper.wait_until do
        not channel.alive_server?
      end

      expect { TCPSocket.new('0.0.0.0', port) }.to raise_error(Errno::ECONNREFUSED)
    end
  end
end

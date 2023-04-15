require "spec_helper"

describe ProconBypassMan::ExternalInput::Channels::TCPIPChannel do
  let(:port) { 9999 }

  describe '.new' do
    it do
      channel = ProconBypassMan::ExternalInput::Channels::TCPIPChannel.new(port: port)
      sleep 1 # NOTE: sleepしないとクライアントから繋げれない

      socket = TCPSocket.new('0.0.0.0', port)
      # write
      message = { buttons: [:a] }.to_json
      socket.write(message)
      response = socket.gets

      # read
      message = "\r\n"
      socket.write(message)
      response = socket.gets
      expect(response).to start_with({ buttons: [:a] }.to_json)

      # read
      message = "\r\n"
      socket.write(message)
      response = socket.gets
      expect(response).to start_with('EMPTY')

      # read
      message = "\r\n"
      socket.write(message)
      response = socket.gets
      expect(response).to start_with('EMPTY')

      channel.shutdown
      # NOTE: threadが実際に停止するまで待機する
      timer = ProconBypassMan::SafeTimeout.new
      loop do
        raise if timer.timeout?
        break if not channel.alive_server?
        sleep 0.5
      end

      expect { TCPSocket.new('0.0.0.0', port) }.to raise_error(Errno::ECONNREFUSED)
    end
  end
end

require 'socket'
require 'procon_bypass_man/support/simple_tcp_server'

describe SimpleTCPServer do
  let(:host) { 'localhost' }
  let(:port) { 8000 }
  let(:server) { SimpleTCPServer.new(host, port) }
  let(:server_thread) { Thread.new { server.run } }

  before do
    server.start_server
    server_thread
  end

  context 'when a client connects' do
    after do
      server.shutdown
      server_thread.kill
    end

    let(:client_socket) { TCPSocket.new(host, port) }

    it 'should add the client to the list of connections' do
      expect(server.connections_size).to eq(0)

      client_socket

      PBMHelper.wait_until do
        server.connections_size >= 1
      end

      expect(server.connections_size).to eq(1)
      server.shutdown
    end

    it 'should call post_init' do
      expect(server).to receive(:post_init).once
      client_socket

      PBMHelper.wait_until do
        server.connections_size >= 1
      end
    end
  end

  context 'when a client sends data' do
    let(:client_socket) { TCPSocket.new(host, port) }

    before do
      client_socket

      PBMHelper.wait_until do
        server.connections_size >= 1
      end
    end

    it 'should call receive_data' do
      expect(server).to receive(:receive_data).once
      client_socket.puts('test data')
      sleep 0.1 # サーバーの処理が完了するまで待つ
    end
  end

  context 'when a client disconnects' do
    let(:client_socket) { TCPSocket.new(host, port) }

    before do
      client_socket

      PBMHelper.wait_until do
        server.connections_size >= 1
      end

      expect(server).to receive(:unbind).once
      server.shutdown

      PBMHelper.wait_until do
        server.connections_size == 0
      end

      server_thread.kill
    end
  end
end

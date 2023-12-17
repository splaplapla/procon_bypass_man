require 'spec_helper'

describe SimpleTCPServer do
  let(:host) { '0.0.0.0' }
  let(:port) {
    server = TCPServer.new(host, 0)
    port = server.addr[1]
    server.close
    port
  }
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

  # FIXME: condition.waitする前にcondition.signalを送るとデッドロックしてしまう問題があるので一旦止める
  xcontext 'when a client sends data' do
    let(:client_socket) { TCPSocket.new(host, port) }

    before do
      client_socket

      PBMHelper.wait_until do
        server.connections_size >= 1
      end
    end

    it 'should call receive_data' do
      # receive_dataが呼ばれるまで処理をブロックするためのmutex
      mutex = Mutex.new
      condition = ConditionVariable.new

      expect(server).to receive(:receive_data).once do
        mutex.synchronize do
          condition.signal
        end
      end

      client_socket.puts('test data')

      mutex.synchronize do
        condition.wait(mutex)
      end
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

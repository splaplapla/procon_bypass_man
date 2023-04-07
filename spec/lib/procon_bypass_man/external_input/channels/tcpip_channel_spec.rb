require "spec_helper"
require "serialport"

describe ProconBypassMan::ExternalInput::Channels::TCPIPChannel do
  let(:port) { 9999 }

  it do
    ProconBypassMan::ExternalInput::Channels::TCPIPChannel.new(port: port)
    sleep 1 # NOTE: sleepしないとクライアントから繋げれない

    socket = TCPSocket.new('0.0.0.0', port)
    # write
    json = { buttons: [:a] }.to_json
    message = "#{json}\r\n"
    socket.write(message)
    response = socket.gets

    # read
    message = "\r\n"
    socket.write(message)
    response = socket.gets
    expect(response).to start_with({ buttons: [:a] }.to_json)

    # read
    # FIXME: なぜか"\r\n"が返ってくる
    message = "\r\n"
    socket.write(message)
    response = socket.gets
    expect(response).to start_with("\r\n")

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

    EventMachine::stop_event_loop
  end
end

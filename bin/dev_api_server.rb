#!/usr/bin/env ruby

require "sinatra"
require "webrick"
require "pry"

post '/api/reports' do
  puts JSON.parse(request.body.read)
  status 200
  body ''
end

post '/api/pressed_buttons' do
  r = JSON.parse(request.body.read)
  puts r
  status 200
  body ''
end

#!/usr/bin/env ruby

require "sinatra"
require "webrick"
require "pry"

post '/api/reports' do
  puts JSON.parse(request.body.read)
  status 200
  body ''
end

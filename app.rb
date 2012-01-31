require 'rubygems'
require 'sinatra'
require './lib/muckraker'
require './models'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/muckraker.db")

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  erb :index
end

get '/*' do
  html :'404'
end

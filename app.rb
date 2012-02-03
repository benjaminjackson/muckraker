require 'rubygems'
require 'sinatra'
require './lib/muckraker'
require './models'
require './stats'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/muckraker.db")

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
	@most_supported_campaigns = Campaign.most_supported
	@most_opposed_campaigns = Campaign.most_opposed
  	erb :index
end

get '/*' do
  File.read(File.join('public', '404.html'))
end
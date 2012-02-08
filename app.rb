require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'json'
require './lib/muckraker'
require './models'
require './stats'
require './partials'
require './helpers'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/muckraker.db")

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
	@most_supported_campaigns = Campaign.most_supported
	@most_supported_campaigns_data = [
		{'name' => 'Total Expenditures', 'data' => @most_supported_campaigns.map { |campaign| campaign.total_expenditures(:support_or_oppose => 'S') } },
		{'name' => 'Total Disbursements of Campaign', 'data' => @most_supported_campaigns.map { |campaign| campaign.total_disbursements } }
	]
	@most_opposed_campaigns = Campaign.most_opposed
	@most_opposed_campaigns_data = [
		{'name' => 'Total Expenditures', 'data' => @most_opposed_campaigns.map { |campaign| campaign.total_expenditures(:support_or_oppose => 'O') } },
	]
  	erb :index
end

get '/527s' do
	@committees = Committee.all.sort { |first, second| first.total_receipts <=> second.total_receipts }.reverse[0..10]
	@committees_data = [
		{'name' => 'Total Receipts', 'data' => @committees.map { |committee| committee.total_receipts } },
		{'name' => 'Total Contributions', 'data' => @committees.map { |committee| committee.total_contributions } },
		{'name' => 'Total from Individuals', 'data' => @committees.map { |committee| committee.total_from_individuals } },
		{'name' => 'Total from PACs', 'data' => @committees.map { |committee| committee.total_from_pacs } }
	]
	erb :'527'
end


get '/*' do
  File.read(File.join('public', '404.html'))
end
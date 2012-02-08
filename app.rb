require 'rubygems'
require 'sinatra'
require './lib/muckraker'
require './models'
require './stats'
require './partials'
require './helpers'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/muckraker.db")

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
	@columns = { :names => ['Campaign', 'Amount'], :types => ['string', 'number'] }
	@most_supported_campaigns = Campaign.most_supported
	@most_supported_campaigns_data = @most_supported_campaigns.map do |campaign|
		[campaign.total_expenditures(:support_or_oppose => 'S'), campaign.total_disbursements]
	end
	@most_opposed_campaigns = Campaign.most_opposed
  	erb :index
end

get '/*' do
  File.read(File.join('public', '404.html'))
end
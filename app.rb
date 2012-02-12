require 'rubygems'
require 'sinatra'
require 'sinatra/simple-navigation'
require "sinatra/reloader" if development?
require 'json'
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

get '/committees' do
	@committees = Committee.all.sort { |first, second| first.total_contributions <=> second.total_contributions }.reverse[0..10]
	@committees_data = [
		{'name' => 'Total from Individuals', 'data' => @committees.map { |committee| committee.total_from_individuals } },
		{'name' => 'Total from PACs', 'data' => @committees.map { |committee| committee.total_from_pacs } }
	]
	@top_expenditures = Committee.all.reject { |c| c.campaign.nil? }.sort { |first, second| first.total_independent_expenditures <=> second.total_independent_expenditures }.reverse[0..10]
	@top_expenditures_data = [
		{'name' => 'Support Ads', 'data' => @top_expenditures.map { |committee| committee.total_independent_expenditures('S') } },
		{'name' => 'Attack Ads', 'data' => @top_expenditures.map { |committee| committee.total_independent_expenditures('O') } }
	]
	erb :committees
end

get '/committee/:id' do
	@committee = Committee.get(params[:id])
	@expenditures = @committee.campaign.independent_expenditures
	@purposes = {}
	@expenditures.each do |exp|
		@purposes[exp.purpose] ||= 0;
		@purposes[exp.purpose] += exp.amount;
	end
	@data = [
		{'name' => 'Breakdown of Expenditures by Purpose', 'data' => @purposes.map { |key, value| value } }
	]

	erb :committee
end

get '/payees/?:party?' do
	@title = "Top Payees"
	@title += " for #{params[:party] == 'dem' ? 'Democrats' : 'Republicans'}" if params[:party]
	params[:party] = params[:party].upcase if params[:party]
	@payees = Committee.top_payees(params[:party])
	@payees_data = [
		{'name' => 'Support Ads', 'data' => @payees.map { |payee_name| Committee.amount_spent_on_payee(payee_name, params[:party], 'S') } },
		{'name' => 'Attack Ads', 'data' => @payees.map { |payee_name| Committee.amount_spent_on_payee(payee_name, params[:party], 'O') } }
	]
	erb :payees
end

get '/*' do
  File.read(File.join('public', '404.html'))
end
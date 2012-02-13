require 'rubygems'
require 'sinatra'
require 'sinatra/simple-navigation'
require "sinatra/reloader" if development?
require 'json'
require './models'
require './stats'
require './partials'
require './helpers'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://postgres:postgres@localhost/muckraker")

DataMapper.finalize
DataMapper.auto_upgrade!

include AppHelpers

before do
	@info = info_for_page
end

get '/' do
	erb :index
end

get '/campaigns' do
	@campaigns = Campaign.money_magnets
	@campaigns_data = [
		{'name' => 'Total Expenditures Supporting', 'data' => @campaigns.map { |campaign| campaign.total_expenditures(:support_or_oppose => 'S') } },
		{'name' => 'Total Expenditures Opposing', 'data' => @campaigns.map { |campaign| campaign.total_expenditures(:support_or_oppose => 'O') } }
	]
	erb :_chart, :locals => { :legend => @campaigns.map { |c| c.name.downcase.titlecase + " (#{c.party[0]})" },
							  :data => @campaigns_data,
							  :stacked => true }
end

get '/campaigns/:support_or_oppose' do
	support = params[:support_or_oppose] == "supported"
	support_or_oppose = support ? 'S' : 'O'
	@campaigns = support ? Campaign.most_supported : Campaign.most_opposed
	@campaigns_data = [
		{'name' => 'Total Expenditures', 'data' => @campaigns.map { |campaign| campaign.total_expenditures(:support_or_oppose => support_or_oppose) } }
	]
	if support
		@campaigns_data << {'name' => 'Total Disbursements of Campaign', 'data' => @campaigns.map { |campaign| campaign.total_disbursements } }

	end
	erb :_chart, :locals => { :legend => @campaigns.map { |c| c.name.downcase.titlecase + " (#{c.party[0]})" },
							  :data => @campaigns_data,
							  :stacked => support}
end


get '/committees' do
	@committees = Committee.all.sort { |first, second| first.total_contributions <=> second.total_contributions }.reverse[0..10]
	@committees_data = [
		{'name' => 'Total from Individuals', 'data' => @committees.map { |committee| committee.total_from_individuals } },
		{'name' => 'Total from PACs', 'data' => @committees.map { |committee| committee.total_from_pacs } }
	]
	erb :_chart, :locals => { :legend => @committees.map { |c| truncate(c.name.downcase.titlecase) + " (#{c.party[0]})" },
							 :data => @committees_data,
							 :stacked => true,
							 :chart_name => "top_contributions" }
end

get '/committees/spenders' do
	@top_expenditures = Committee.all.to_a.reject { |c| c.campaign.nil? }.sort { |first, second|
		first.total_independent_expenditures <=>
		second.total_independent_expenditures
	}.reverse[0..10]
	@top_expenditures_data = [
		{'name' => 'Support Ads', 'data' => @top_expenditures.map { |committee| committee.total_independent_expenditures('S') } },
		{'name' => 'Attack Ads', 'data' => @top_expenditures.map { |committee| committee.total_independent_expenditures('O') } }
	]
	erb :_chart, :locals => { :legend => @top_expenditures.map { |c| truncate(c.name.downcase.titlecase) + " (#{c.party[0]})" },
							  :data => @top_expenditures_data,
							  :urls => @top_expenditures.map { |c| "/committee/#{c.id}"},
							  :stacked => true,
							  :chart_name => "top_expenditures" }
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

	erb :committee, :layout => :committee_layout
end

get '/payees/?:party?' do
	@title = "Top Payees"
	@title += " for #{params[:party] == 'dem' ? 'Democratic' : 'Republican'} Campaigns" if params[:party]
	params[:party] = params[:party].upcase if params[:party]
	@payees = Committee.top_payees(params[:party])
	@payees_data = [
		{'name' => 'Support Ads', 'data' => @payees.map { |payee_name| Committee.amount_spent_on_payee(payee_name, params[:party], 'S') } },
		{'name' => 'Attack Ads', 'data' => @payees.map { |payee_name| Committee.amount_spent_on_payee(payee_name, params[:party], 'O') } }
	]
	@sidebar_text = "Committees can spend money on ads which expressly advocate for the election or defeat of a candidate, as long as the expense is not done in coordination with the candidate, candidate's authorized committee or a political party."
	erb :payees
end

get '/*' do
  File.read(File.join('public', '404.html'))
end
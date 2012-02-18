require 'rubygems'
require 'sinatra'
require 'sinatra/simple-navigation'
require "sinatra/reloader" if development?
require 'json'
require './models'
require './stats'
require './partials'
require './helpers'


class Muckraker::Application < Sinatra::Application
	set :root, Dir.pwd
	set :public_folder, "#{Dir.pwd}/public"

	DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://postgres:postgres@localhost/muckraker")

	DataMapper.finalize
	DataMapper.auto_upgrade!

	include AppHelpers

	before do
		@info = info_for_page
	    if settings.environment != :development
		    cache_control :public, :max_age => 864000 # 10d cache expiry
		end
	end

	get '/' do
		erb :index
	end

	get '/campaigns' do
		@campaigns = Campaign.money_magnets
		@data = [
			{'name' => 'Total Expenditures Supporting', 'data' => @campaigns.map { |campaign| campaign.total_expenditures(:support_or_oppose => 'S') } },
			{'name' => 'Total Expenditures Opposing', 'data' => @campaigns.map { |campaign| campaign.total_expenditures(:support_or_oppose => 'O') } }
		]
		erb :_chart, :locals => { :legend => @campaigns.map { |c| c.name.downcase.titlecase + " (#{c.party[0]})" },
								  :data => @data,
								  :stacked => true }
	end

	get '/campaigns/:support_or_oppose' do
		support = params[:support_or_oppose] == "supported"
		support_or_oppose = support ? 'S' : 'O'
		@campaigns = support ? Campaign.most_supported : Campaign.most_opposed
		@data = [
			{'name' => 'Total Expenditures', 'data' => @campaigns.map { |campaign| campaign.total_expenditures(:support_or_oppose => support_or_oppose) } }
		]
		if support
			@data << {'name' => 'Total Disbursements of Campaign', 'data' => @campaigns.map { |campaign| campaign.total_disbursements } }

		end
		erb :_chart, :locals => { :legend => @campaigns.map { |c| c.name.downcase.titlecase + " (#{c.party[0]})" },
								  :data => @data,
								  :stacked => support}
	end


	get '/committees' do
		@committees = Committee.all.sort { |first, second| first.total_contributions <=> second.total_contributions }.reverse[0..10]
		@data = [
			{'name' => 'Total from Individuals', 'data' => @committees.map { |committee| committee.total_from_individuals } },
			{'name' => 'Total from PACs', 'data' => @committees.map { |committee| committee.total_from_pacs } }
		]
		erb :_chart, :locals => { :legend => @committees.map { |c| truncate(c.name.downcase.titlecase) + " (#{c.party[0]})" },
								 :data => @data,
								 :stacked => true,
								 :urls => @committees.map { |c| "/committee/#{c.id}"},
								 :chart_name => "top_contributions" }
	end

	get '/committees/spenders' do
		@committees = Committee.top_spenders
		@data = [
			{'name' => 'Support Ads', 'data' => @committees.map { |committee| committee.total_independent_expenditures('S') } },
			{'name' => 'Attack Ads', 'data' => @committees.map { |committee| committee.total_independent_expenditures('O') } }
		]
		erb :_chart, :locals => { :legend => @committees.map { |c| truncate(c.name.downcase.titlecase) + " (#{c.party[0]})" },
								  :data => @data,
								  :urls => @committees.map { |c| "/committee/#{c.id}"},
								  :stacked => true }
	end

	get '/committee/:id' do
		@committee = Committee.get(params[:id])
		@campaigns = @committee.top_campaigns
		@data = [
			{'name' => 'Support Ads', 'data' => @campaigns.map { |campaign| @committee.expenditures_supporting(campaign) } },
			{'name' => 'Attack Ads', 'data' => @campaigns.map { |campaign| @committee.expenditures_opposing(campaign) } }
		]
		erb :_chart, :layout => :committee_layout,
					 :locals => { :legend => @campaigns.map { |c| truncate(c.name.downcase.titlecase) + " (#{c.party[0]})" },
								  :data => @data,
								  :stacked => true }
	end

	get '/committee/:id/purpose' do
		@committee = Committee.get(params[:id])
		@expenditures = @committee.independent_expenditures
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
		@data = [
			{'name' => 'Support Ads', 'data' => @payees.map { |payee_name| Committee.amount_spent_on_payee(payee_name, params[:party], 'S') } },
			{'name' => 'Attack Ads', 'data' => @payees.map { |payee_name| Committee.amount_spent_on_payee(payee_name, params[:party], 'O') } }
		]
		@sidebar_text = "Committees can spend money on ads which expressly advocate for the election or defeat of a candidate, as long as the expense is not done in coordination with the candidate, candidate's authorized committee or a political party."
		erb :_chart, :locals => { :legend => @payees.map { |c| truncate(c) },
								  :data => @data,
								  :chart_name => "top_payees",
								  :stacked => true }
	end

	get '/*' do
	  File.read(File.join('public', '404.html'))
	end
end

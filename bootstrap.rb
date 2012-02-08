require 'campaign_cash'
require './lib/muckraker'
require './models'

class Muckraker::Bootstrap
	def self.load
        CampaignCash::Base.api_key = ENV['API_KEY']
		load_candidates
		load_expenditures
	end

	def self.load_candidates
        puts "Loading congressional candidates..."
    	@candidates = Muckraker::US_STATES.map do |state|
            puts "Loading candidates for #{state}..."
  			CampaignCash::Candidate.state_chamber(state, 'senate') + CampaignCash::Candidate.state_chamber(state, 'house')
		end.flatten

		c = CampaignCash::Candidate.new
       	props = Campaign.properties.to_ary.map { |p| p.name }.select { |p| c.respond_to? p }

        @candidates.each do |candidate|
            full_candidate = CampaignCash::Candidate.find(candidate.id)
        	attrs = Hash[props.map { |name|	[name, full_candidate.send(name)] }]
        	attrs['id'] = nil
        	attrs['remote_id'] = full_candidate.id
        	Campaign.first_or_create({:remote_id => full_candidate.id}, attrs)
        end
	end

	def self.load_expenditures
		e = CampaignCash::IndependentExpenditure.new
       	props = IndependentExpenditure.properties.to_ary.map { |p| p.name }.select { |p| e.respond_to? p }
       	total_expenditures = 0
        Campaign.all.each_with_index do |campaign, index|
            puts "Loading expenditures for candidate #{index + 1} of #{Campaign.count}: #{campaign.name}, #{campaign.office}..."
            expenditures = CampaignCash::IndependentExpenditure.candidate(campaign.remote_id, 2012)
            puts expenditures.length
            total_expenditures += expenditures.length
            expenditures.each do |exp|
        		attrs = Hash[props.map { |name| [name, exp.send(name)] }]
        		attrs[:amount] = attrs[:amount].to_f * 10
        		attrs[:campaign] = campaign
            	independent_exp = IndependentExpenditure.first_or_create({:transaction_id => attrs[:transaction_id], :date_received => attrs[:date_received]}, attrs)
            end
        end
        puts "total_expenditures"
        puts total_expenditures
        puts "count:"
        puts IndependentExpenditure.count
	end
end


DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/muckraker_new.db")

DataMapper.finalize
DataMapper.auto_upgrade!

DataMapper::Model.raise_on_save_failure = true  # globally across all models

Muckraker::Bootstrap.load
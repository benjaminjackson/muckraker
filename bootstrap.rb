require 'campaign_cash'
require './models'

module Muckraker
    class Bootstrap
        US_STATES = [:AL, :AK, :AZ, :AR, :CA, :CO, :CT, :DE, :FL, :GA, :HI, :ID, :IL, :IN, :IA, :KS, :KY, :LA, :ME, :MD,
                     :MA, :MI, :MN, :MS, :MO, :MT, :NE, :NV, :NH, :NJ, :NM, :NY, :NC, :ND, :OH, :OK, :OR, :PA, :RI, :SC,
                     :SD, :TN, :TX, :UT, :VT, :VA, :WA, :WV, :WI, :WY]
    	def self.load
            CampaignCash::Base.api_key = ENV['API_KEY']
            load_candidates
            load_superpacs
    		load_expenditures
    	end

    	def self.load_candidates
            puts "Loading congressional candidates..."
        	@candidates = US_STATES.map do |state|
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
            	campaign = Campaign.first_or_create({:remote_id => full_candidate.id}, attrs)
                load_committee_for_candidate(candidate, campaign)
            end
    	end

        def self.load_committee_for_candidate candidate, campaign
            if candidate.committee_id
                puts "Loading committee for candidate #{candidate.name}, #{candidate.office}..."
                committee = CampaignCash::Committee.find(candidate.committee_id)
                create_committee(committee, campaign)
            end
        end

        def self.create_committee committee, campaign=nil
            c = CampaignCash::Committee.new
            props = Committee.properties.to_ary.map { |p| p.name }.select { |p| c.respond_to? p }
            attrs = Hash[props.map { |name| [name, committee.send(name)] }]
            attrs['id'] = nil
            attrs['remote_id'] = committee.id
            attrs['campaign'] = campaign
            attrs.keys.each { |key| attrs[key] = attrs[key].to_f if key.to_s.include?('total_') }
            Committee.first_or_create({:remote_id => committee.id}, attrs)
        end

        def self.load_superpacs
            CampaignCash::Committee.superpacs.each do |committee|
                create_committee(CampaignCash::Committee.find(committee.id))
            end
        end

    	def self.load_expenditures
    		e = CampaignCash::IndependentExpenditure.new
           	props = IndependentExpenditure.properties.to_ary.map { |p| p.name }.select { |p| e.respond_to? p }
           	total_expenditures = 0
            Campaign.all.each_with_index do |campaign, index|
                puts "Loading expenditures for candidate #{index + 1} of #{Campaign.count}: #{campaign.name}, #{campaign.office}..."
                expenditures = CampaignCash::IndependentExpenditure.candidate(campaign.remote_id, 2012)
                total_expenditures += expenditures.length
                expenditures.each do |exp|
            		attrs = Hash[props.map { |name| [name, exp.send(name)] }]
            		attrs[:amount] = attrs[:amount].to_f * 10
                    attrs[:campaign] = campaign
                    attrs[:payee] = attrs[:payee].gsub(',', '')
            		attrs[:committee] = create_committee(CampaignCash::Committee.find(exp.committee))
                    attrs.keys.each { |key| attrs[key] = attrs[key].to_f if key.to_s.include?('total_') }
                	independent_exp = IndependentExpenditure.first_or_create({:transaction_id => attrs[:transaction_id], :date_received => attrs[:date_received]}, attrs)
                end
            end
            puts "Total Expenditures:"
            puts IndependentExpenditure.count
    	end
    end
end


DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://postgres:postgres@localhost/muckraker")

DataMapper.finalize
DataMapper.auto_upgrade!

DataMapper::Model.raise_on_save_failure = true  # globally across all models

Muckraker::Bootstrap.load
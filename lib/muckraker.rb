require 'rubygems'
require 'campaign_cash'

class Muckraker

	include CampaignCash

    US_STATES = [:AL, :AK, :AZ, :AR, :CA, :CO, :CT, :DE, :FL, :GA, :HI, :ID, :IL, :IN, :IA, :KS, :KY, :LA, :ME, :MD, 
                 :MA, :MI, :MN, :MS, :MO, :MT, :NE, :NV, :NH, :NJ, :NM, :NY, :NC, :ND, :OH, :OK, :OR, :PA, :RI, :SC, 
                 :SD, :TN, :TX, :UT, :VT, :VA, :WA, :WV, :WI, :WY]

    attr_accessor :candidates

    def initialize(api_key)
   		Base.api_key = api_key
    end

    def load
    	load_candidates
    	@expenditures = []
    	@candidates.each do |candidate|
    		load_expenditures(candidate.candidate_id)
    	end		
    end

    def total_contributions_by_contributor
  		contributors = {}
		@expenditures.each do |exp|
            payee_name = exp.payee + " (#{exp.support_or_oppose == 'O' ? 'Against' : 'For'})"
	    	contributors[payee_name] ||= 0
	    	contributors[payee_name] += exp.amount
	    end
        contributors
    end

    private

    def load_candidates
    	@candidates = US_STATES.map do |state|
  			Candidate.state_chamber(state, 'senate') + Candidate.state_chamber(state, 'house')
		end.flatten
    end

    def load_expenditures(candidate_id, year=2012)
		candidate_expenditures = IndependentExpenditure.candidate(candidate_id, year)
    	@expenditures << candidate_expenditures
        @expenditures.flatten!
    end

end
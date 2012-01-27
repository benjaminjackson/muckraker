require 'rubygems'
require 'campaign_cash'
require 'yaml'
require 'fileutils'

class Muckraker

	include CampaignCash

    US_STATES = [:AL, :AK, :AZ, :AR, :CA, :CO, :CT, :DE, :FL, :GA, :HI, :ID, :IL, :IN, :IA, :KS, :KY, :LA, :ME, :MD, 
                 :MA, :MI, :MN, :MS, :MO, :MT, :NE, :NV, :NH, :NJ, :NM, :NY, :NC, :ND, :OH, :OK, :OR, :PA, :RI, :SC, 
                 :SD, :TN, :TX, :UT, :VT, :VA, :WA, :WV, :WI, :WY]

    CACHE_DIR = File.expand_path "~/.muckraker/cache"
    CANDIDATES_CACHE_FILENAME = 'candidates.yaml'
    EXPENDITURES_CACHE_FILENAME = 'expenditures.yaml'

    attr_accessor :cache, :candidates, :expenditures, :payees

    def initialize(api_key)
   		Base.api_key = api_key
    end

    def cache=cache
        @cache = cache
        if cache
            FileUtils.mkdir_p CACHE_DIR
        end
    end

    def load
        if cache && has_cached_data?
            load_from_cache
        else 
            load_candidates
            load_expenditures
        end
    end

    def load_from_cache
        @candidates = YAML::load File.join(CACHE_DIR, CANDIDATES_CACHE_FILENAME)
        @expenditures = YAML::load File.join(CACHE_DIR, EXPENDITURES_CACHE_FILENAME)
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
        if cache
            File.open(File.join(CACHE_DIR, CANDIDATES_CACHE_FILENAME), 'w') do |f|
                f.write YAML::dump(@candidates)
            end
        end
    end

    def has_cached_data?
        [CANDIDATES_CACHE_FILENAME, EXPENDITURES_CACHE_FILENAME].each do |filename|
            return false unless File.exists?(File.join(CACHE_DIR, filename))
        end
        true
    end

    def load_expenditures
        @expenditures = []
        @candidates.each do |candidate|
            load_expenditures_for_candidate(candidate.id)
        end     
        if cache
            File.open(File.join(CACHE_DIR, EXPENDITURES_CACHE_FILENAME), 'w') do |f|
                f.write YAML::dump(@expenditures)
            end
        end        
    end

    def load_expenditures_for_candidate(candidate_id, year=2012)
		candidate_expenditures = IndependentExpenditure.candidate(candidate_id, year)
    	@expenditures << candidate_expenditures
        @expenditures.flatten!
    end

end

# Usage: 
# 
# API_KEY = '160748e2412352af46f3fe7c75cce5fd:15:63511996'
# m = Muckraker.new(API_KEY)
# m.cache = true
# m.load
require 'rspec'
require 'muckraker'
require 'fileutils'

API_KEY = '160748e2412352af46f3fe7c75cce5fd:15:63511996'
DEFAULT_EXPENDITURE = 1000.0

include CampaignCash

def prepare_for_load
	@muckraker = Muckraker.new(API_KEY)
	@expenditure = mock('expenditure')
	@expenditure.stub(:payee).and_return("Evil Corp. International")
	@expenditure.stub(:support_or_oppose).and_return("O")
	@expenditure.stub(:amount).and_return(DEFAULT_EXPENDITURE)
	@candidate = mock('candidate')
	@candidate.stub(:id).and_return('P60003654')
	IndependentExpenditure.stub(:candidate).and_return([@expenditure])
	Candidate.stub(:state_chamber).and_return([])
	Candidate.stub(:state_chamber).with(:DE, 'house').and_return([@candidate])
end

def load_expenditures
	@muckraker = Muckraker.new(API_KEY)

	@expenditure = mock('expenditure')
	@expenditure.stub(:payee).and_return("Evil Corp. International")
	@expenditure.stub(:support_or_oppose).and_return("O")
	@expenditure.stub(:amount).and_return(FIRST_EXPENDITURE)

	@another_expenditure = mock('another expenditure')
	@another_expenditure.stub(:payee).and_return("Shameless Astroturf, Inc.")
	@another_expenditure.stub(:support_or_oppose).and_return("O")
	@another_expenditure.stub(:amount).and_return(SECOND_EXPENDITURE)

	@top_expenditure = mock('a really expensive expenditure')
	@top_expenditure.stub(:payee).and_return("Newscorp, Intl.")
	@top_expenditure.stub(:support_or_oppose).and_return("S")
	@top_expenditure.stub(:amount).and_return(TOP_EXPENDITURE)

	@candidate = mock('candidate')
	@candidate.stub(:id).and_return('P60003654')
	@candidate.stub(:party).and_return('REP')
	IndependentExpenditure.stub(:candidate).and_return([@expenditure, @another_expenditure, @top_expenditure])
	Candidate.stub(:state_chamber).and_return([])
	Candidate.stub(:state_chamber).with(:DE, 'house').and_return([@candidate])

	[@expenditure, @another_expenditure, @top_expenditure].each do |exp|
		exp.stub(:candidate).and_return(@candidate.id)
	end

	@muckraker.load
end

def clear_cache
	FileUtils.rm_r(Muckraker::CACHE_DIR) if File.exists?(Muckraker::CACHE_DIR)
end
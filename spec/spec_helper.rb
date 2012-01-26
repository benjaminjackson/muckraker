require 'rspec'
require 'muckraker'

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
	@candidate.stub(:candidate_id).and_return('P60003654')
	IndependentExpenditure.stub(:candidate).and_return([@expenditure])
	Candidate.stub(:state_chamber).and_return([])
	Candidate.stub(:state_chamber).with(:DE, 'house').and_return([@candidate])
end
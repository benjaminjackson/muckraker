require 'rspec'
require 'muckraker'

API_KEY = '160748e2412352af46f3fe7c75cce5fd:15:63511996'
DEFAULT_EXPENDITURE = 1000.0

include CampaignCash

describe Muckraker, "when loading data" do
	before do
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
	it "should retrieve all candidates" do
		Muckraker::US_STATES.each do |state|
			Candidate.should_receive(:state_chamber).with(state, 'senate').at_least(1).times.and_return([])
			Candidate.should_receive(:state_chamber).with(state, 'house').at_least(1).times.and_return([])
		end
		@muckraker.load
    end
	it "should assign all to the candidates variable" do
		Candidate.stub(:state_chamber).and_return([])
		@muckraker.load
		@muckraker.candidates.should be_empty
    end
	it "should retrieve all independent expenditures for all candidates" do
		IndependentExpenditure.should_receive(:candidate).with('P60003654', 2012).and_return([@expenditure])
		@muckraker.load
    end
	it "should sum up the expenditures into the contributors map under the payee's name and campaign position" do
		first_amount = 500
		second_amount = 1000

		@expenditure.stub(:amount).and_return(first_amount)		
		@muckraker.load
		@muckraker.contributors['Evil Corp. International (Against)'].should == first_amount

		@another_expenditure = mock('another expenditure')
		@another_expenditure.stub(:payee).and_return("Evil Corp. International")
		@another_expenditure.stub(:support_or_oppose).and_return("O")
		@another_expenditure.stub(:amount).and_return(second_amount)

		IndependentExpenditure.stub(:candidate).and_return([@expenditure, @another_expenditure])

		@muckraker.load
		@muckraker.contributors['Evil Corp. International (Against)'].should == first_amount + second_amount

    end
end
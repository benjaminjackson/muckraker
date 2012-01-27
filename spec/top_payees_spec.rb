require "#{File.dirname(__FILE__)}/spec_helper"

FIRST_EXPENDITURE = 100000.0
SECOND_EXPENDITURE = 50000.0
TOP_EXPENDITURE = 70000000.0

describe Muckraker, "when calculating the top contributors" do
	before do
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
		IndependentExpenditure.stub(:candidate).and_return([@expenditure, @another_expenditure, @top_expenditure])
		Candidate.stub(:state_chamber).and_return([])
		Candidate.stub(:state_chamber).with(:DE, 'house').and_return([@candidate])

		[@expenditure, @another_expenditure, @top_expenditure].each do |exp|
			exp.stub(:candidate).and_return(@candidate.id)
		end

		@muckraker.load
	end

	describe "for both parties" do 
		it "should return all payees in order of who contributed the most" do
			@muckraker.top_payees.legend.should == [@top_expenditure.payee, @expenditure.payee, @another_expenditure.payee]
		end
	end

	describe "for democrats" do 
		it "should return all payees for or against democrats in order of who contributed the most" do
			@candidate.stub(:party).and_return('REP')
			@muckraker.top_payees('DEM').legend.should == []
			@candidate.stub(:party).and_return('DEM')
			@muckraker.top_payees('DEM').legend.should == [@top_expenditure.payee, @expenditure.payee, @another_expenditure.payee]
		end
	end

	describe "for republicans" do 
		it "should return all payees for or against republicans in order of who contributed the most" do
			@candidate.stub(:party).and_return('DEM')
			@muckraker.top_payees('REP').legend.should == []
			@candidate.stub(:party).and_return('REP')
			@muckraker.top_payees('REP').legend.should == [@top_expenditure.payee, @expenditure.payee, @another_expenditure.payee]
		end
	end
end
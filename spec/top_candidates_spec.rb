require "#{File.dirname(__FILE__)}/spec_helper"

include SpecHelper

describe Muckraker, "when calculating the most-supported candidates" do
	before do
		prepare_lots_of_expenditures('S')
		@muckraker.load
	end
	it "should return the candidates with the highest total amount spent" do
		top_candidates = @muckraker.top_supported_candidates
		top_candidates.legend.first.should == @candidates.last.name + " (#{@candidates.last.party}, #{@candidates.last.office})"
		last_index = @candidates.length - Muckraker::DEFAULT_LIMIT
		top_candidates.legend.last.should == @candidates[last_index].name + " (#{@candidates[last_index].party}, #{@candidates[last_index].office})"
	end
	it "should return the candidates' ids in the same order they appear in the legend" do
		top_candidates = @muckraker.top_supported_candidates
		top_candidates.legend_ids.first.should == @candidates.last.id
		last_index = @candidates.length - Muckraker::DEFAULT_LIMIT
		top_candidates.legend_ids.last.should == @candidates[last_index].id
	end
	it "should limit results to the specified limit" do
		@muckraker.top_supported_candidates(nil, 20).legend.length.should == 20
	end
	it "should not alter the main expenditures list" do
		@senate_candidate = FactoryGirl.build(:candidate, :name => @candidates.last.name, :party => @candidates.last.party, :office => 'senate')
		Candidate.stub(:state_chamber).with(:DE, 'senate').and_return([@senate_candidate])
		@super_high_expenditure = FactoryGirl.build(:expenditure, :candidate => @senate_candidate.id, :support_or_oppose => 'O', :amount => SUPER_HIGH_EXPENDITURE_VALUE)
		@expenditures << @super_high_expenditure
		IndependentExpenditure.stub(:candidate).with(@senate_candidate.id, 2012).and_return([@super_high_expenditure])
		@muckraker.load

		top_candidates = @muckraker.top_supported_candidates
		@muckraker.expenditures.length.should == @expenditures.length
	end
end

describe Muckraker, "when calculating the most-opposed candidates" do
	before do
		prepare_lots_of_expenditures('O')
		@muckraker.load
	end
	it "should show the candidate with the highest total amount spent" do
		top_candidates = @muckraker.top_opposed_candidates
		top_candidates.legend.first.should == @candidates.last.name + " (#{@candidates.last.party}, #{@candidates.last.office})"
		last_index = @candidates.length - Muckraker::DEFAULT_LIMIT
		top_candidates.legend.last.should == @candidates[last_index].name + " (#{@candidates[last_index].party}, #{@candidates[last_index].office})"
	end
	it "should return the candidates' ids in the same order they appear in the legend" do
		top_candidates = @muckraker.top_opposed_candidates
		top_candidates.legend_ids.first.should == @candidates.last.id
		last_index = @candidates.length - Muckraker::DEFAULT_LIMIT
		top_candidates.legend_ids.last.should == @candidates[last_index].id
	end
	it "should limit results to the specified limit" do
		@muckraker.top_opposed_candidates(nil, 20).legend.length.should == 20
	end

end

describe Muckraker, "when calculating the most-supported candidates with a candidate that has both house and senate campaigns" do
	before do
		prepare_lots_of_expenditures('S')
		@senate_candidate = FactoryGirl.build(:candidate, :name => @candidates.last.name, :party => @candidates.last.party, :office => 'senate')
		Candidate.stub(:state_chamber).with(:DE, 'senate').and_return([@senate_candidate])
	end

	describe "and the senate campaign has no expenditures" do
		before do
			IndependentExpenditure.stub(:candidate).with(@senate_candidate.id, 2012).and_return([])
			@muckraker.load
		end
		it "should not include the senate campaign's id in the legend_ids" do
			@muckraker.top_supported_candidates.legend_ids.should_not include(@senate_candidate.id)
		end
		it "should include the house campaign's id in the legend_ids" do
			@muckraker.top_supported_candidates.legend_ids.should include(@candidates.last.id)
		end
	end

	describe "and the senate campaign has the highest expenditures" do
		before do
			@super_high_expenditure = FactoryGirl.build(:expenditure, :candidate => @senate_candidate.id, :support_or_oppose => 'S', :amount => SUPER_HIGH_EXPENDITURE_VALUE)
			IndependentExpenditure.stub(:candidate).with(@senate_candidate.id, 2012).and_return([@super_high_expenditure])
			@muckraker.load
		end
		it "should include the senate campaign's id in the legend_ids" do
			@muckraker.top_supported_candidates.legend_ids.should include(@senate_candidate.id)
		end
		it "should also include the house campaign's id in the legend_ids" do
			@muckraker.top_supported_candidates.legend_ids.should include(@candidates.last.id)
		end
	end

	describe "and the senate campaign has no committee assigned, but has the highest expenditures" do
		before do
			@committeeless_senate_candidate = FactoryGirl.build(:candidate, :name => @candidates.last.name, :party => @candidates.last.party, :office => 'senate', :committee_id => nil)
			@super_high_expenditure = FactoryGirl.build(:expenditure, :candidate => @committeeless_senate_candidate.id, :support_or_oppose => 'S', :amount => SUPER_HIGH_EXPENDITURE_VALUE)
			IndependentExpenditure.stub(:candidate).with(@committeeless_senate_candidate.id, 2012).and_return([@super_high_expenditure])
			Candidate.stub(:state_chamber).with(:DE, 'senate').and_return([@committeeless_senate_candidate])
			@muckraker.load
		end
		it "should not include the senate campaign's id in the legend_ids" do
			@muckraker.top_supported_candidates.legend_ids.should_not include(@committeeless_senate_candidate.id)
		end
		it "should include the house campaign's id in the legend_ids" do
			@muckraker.top_supported_candidates.legend_ids.should include(@candidates.last.id)
		end
	end
end
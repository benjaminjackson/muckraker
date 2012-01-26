require "#{File.dirname(__FILE__)}/spec_helper"

describe Muckraker, "when loading data" do
	before do
		prepare_for_load
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
end
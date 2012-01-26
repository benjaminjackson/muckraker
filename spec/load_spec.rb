require 'rspec'
require 'muckraker'

API_KEY = '160748e2412352af46f3fe7c75cce5fd:15:63511996'

include CampaignCash

describe Muckraker do
	before do
		@muckraker = Muckraker.new(API_KEY)
	end
	describe "when loading" do
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
  	end
end
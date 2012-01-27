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
    describe "when setting cache to true" do
    	it "should create the cache directory" do
    		FileUtils.should_receive(:mkdir_p).with(Muckraker::CACHE_DIR)
    		@muckraker.cache = true
    	end
	end
    describe "with cache set to true and no cached data" do
    	before do
    		clear_cache
    		@muckraker.cache = true
    	end
    	it "should write the data to cache" do
    		YAML.should_receive(:dump).with([@candidate]).and_return("")
    		YAML.should_receive(:dump).with([@expenditure]).and_return("")
    		@muckraker.load
    	end
	end
    describe "with cache set to true and existing cached data" do
    	before do
    		@muckraker.cache = true
			@muckraker.load    		
    	end
    	it "should read the data from cache" do
    		YAML.should_receive(:load).at_least(2).times
            File.should_receive(:open).at_least(2).times.and_return(mock("file", :read => ''))
    		@muckraker.load
    	end
    	it "should not hit the server" do
    		Candidate.should_not_receive(:state_chamber)
    		IndependentExpenditure.should_not_receive(:candidate)
    		@muckraker.load
    	end
    end
end
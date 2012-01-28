require "#{File.dirname(__FILE__)}/spec_helper"

include SpecHelper

describe Muckraker, "when calculating the most-supported candidates" do
	before do
		load_lots_of_expenditures('S')
	end
	it "should return the candidates with the highest total amount spent" do
		top_candidates = @muckraker.top_supported_candidates
		top_candidates.legend.first.should == @candidates.last.name + " (#{@candidates.last.party})"
		last_index = @candidates.length - Muckraker::DEFAULT_LIMIT
		top_candidates.legend.last.should == @candidates[last_index].name + " (#{@candidates[last_index].party})"
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
end

describe Muckraker, "when calculating the most-opposed candidates" do
	before do
		load_lots_of_expenditures('O')
	end
	it "should show the candidate with the highest total amount spent" do
		top_candidates = @muckraker.top_opposed_candidates
		top_candidates.legend.first.should == @candidates.last.name + " (#{@candidates.last.party})"
		last_index = @candidates.length - Muckraker::DEFAULT_LIMIT
		top_candidates.legend.last.should == @candidates[last_index].name + " (#{@candidates[last_index].party})"
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
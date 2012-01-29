require "#{File.dirname(__FILE__)}/spec_helper"

include SpecHelper

describe Muckraker, "when calculating the top committees for a candidate" do
	before do
		load_expenditures
	end

	it "should return all committees for or against that candidate in order of who contributed the most" do
		@muckraker.top_committees_for_candidate(@republican.id).legend.should == [@expenditure.committee_name.normalize, @another_expenditure.committee_name.normalize]
		@muckraker.top_committees_for_candidate(@democrat.id).legend.should == [@top_expenditure.committee_name.normalize]
	end

	describe "with a limit" do
		it "should only return a limited number of results" do
			@muckraker.top_committees_for_candidate(@republican.id, nil, 1).legend.should == [@expenditure.committee_name.normalize]
		end
	end
end
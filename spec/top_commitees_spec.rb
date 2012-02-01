require "#{File.dirname(__FILE__)}/spec_helper"

include SpecHelper

describe Muckraker, "when calculating the top committees" do
	before do
		load_expenditures
	end

	describe "for both parties" do
		it "should return all committees in order of who contributed the most" do
			@muckraker.top_committees.legend.should == [@top_expenditure.committee_name.normalize,
			                                            @expenditure.committee_name.normalize,
			                                            @another_expenditure.committee_name.normalize]
		end
		describe "with a limit" do
			it "should only return a limited number of results" do
				@muckraker.top_committees(nil, nil, 2).legend.should == [@top_expenditure.committee_name.normalize, @expenditure.committee_name.normalize]
			end
		end
	end

	describe "for democrats" do
		it "should return all committees for or against democrats in order of who contributed the most" do
			@muckraker.top_committees('DEM').legend.should == [@top_expenditure.committee_name.normalize]
		end
	end

	describe "for republicans" do
		it "should return all committees for or against republicans in order of who contributed the most" do
			@muckraker.top_committees('REP').legend.should == [@expenditure.committee_name.normalize, @another_expenditure.committee_name.normalize]
		end
		describe "with a limit" do
			it "should only return a limited number of results" do
				@muckraker.top_committees(nil, nil, 1).legend.should == [@top_expenditure.committee_name.normalize]
			end
		end
	end

end

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
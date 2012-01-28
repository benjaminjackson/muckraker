require "#{File.dirname(__FILE__)}/spec_helper"

describe Muckraker, "when calculating the top contributors" do
	before do
		load_expenditures
	end

	describe "for both parties" do 
		it "should return all payees in order of who contributed the most" do
			@muckraker.top_payees.legend.should == [@top_expenditure.payee.normalize, @expenditure.payee.normalize, @another_expenditure.payee.normalize]
		end
		describe "with a limit" do 
			it "should only return a limited number of results" do
				@muckraker.top_payees(nil, nil, 2).legend.should == [@top_expenditure.payee.normalize, @expenditure.payee.normalize]
			end
		end
	end

	describe "for democrats" do 
		it "should return all payees for or against democrats in order of who contributed the most" do
			@muckraker.top_payees('DEM').legend.should == [@top_expenditure.payee.normalize]
		end
	end

	describe "for republicans" do 
		it "should return all payees for or against republicans in order of who contributed the most" do
			@muckraker.top_payees('REP').legend.should == [@expenditure.payee.normalize, @another_expenditure.payee.normalize]
		end
		describe "with a limit" do 
			it "should only return a limited number of results" do
				@muckraker.top_payees(nil, nil, 1).legend.should == [@top_expenditure.payee.normalize]
			end
		end
	end
end

describe Muckraker, "when calculating the top contributors for a candidate" do
	before do
		load_expenditures
	end

	it "should return all payees for or against that candidate in order of who contributed the most" do
		@muckraker.top_payees_for_candidate(@republican.id).legend.should == [@expenditure.payee.normalize, @another_expenditure.payee.normalize]
		@muckraker.top_payees_for_candidate(@democrat.id).legend.should == [@top_expenditure.payee.normalize]
	end
	describe "with a limit" do 
		it "should only return a limited number of results" do
			@muckraker.top_payees_for_candidate(@republican.id, nil, 1).legend.should == [@expenditure.payee.normalize]
		end
	end
end
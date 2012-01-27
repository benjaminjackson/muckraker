require "#{File.dirname(__FILE__)}/spec_helper"

FIRST_EXPENDITURE = 100000.0
SECOND_EXPENDITURE = 50000.0
TOP_EXPENDITURE = 70000000.0

describe Muckraker, "when calculating the top contributors" do
	before do
		load_expenditures
	end

	describe "for both parties" do 
		it "should return all payees in order of who contributed the most" do
			@muckraker.top_payees.legend.should == [@top_expenditure.payee.normalize, @expenditure.payee.normalize, @another_expenditure.payee.normalize]
		end
	end

	describe "for democrats" do 
		it "should return all payees for or against democrats in order of who contributed the most" do
			@candidate.stub(:party).and_return('REP')
			@muckraker.top_payees('DEM').legend.should == []
			@candidate.stub(:party).and_return('DEM')
			@muckraker.top_payees('DEM').legend.should == [@top_expenditure.payee.normalize, @expenditure.payee.normalize, @another_expenditure.payee.normalize]
		end
	end

	describe "for republicans" do 
		it "should return all payees for or against republicans in order of who contributed the most" do
			@candidate.stub(:party).and_return('DEM')
			@muckraker.top_payees('REP').legend.should == []
			@candidate.stub(:party).and_return('REP')
			@muckraker.top_payees('REP').legend.should == [@top_expenditure.payee.normalize, @expenditure.payee.normalize, @another_expenditure.payee.normalize]
		end
	end
end
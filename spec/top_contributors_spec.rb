require "#{File.dirname(__FILE__)}/spec_helper"


describe Muckraker, "when calculating the top contributors" do
	before do
		prepare_for_load
	end
	it "should sum up the expenditures into the contributors map under the payee's name and campaign position" do
		first_amount = 500
		second_amount = 1000

		@expenditure.stub(:amount).and_return(first_amount)
		@muckraker.load
		@muckraker.total_contributions_by_contributor['Evil Corp. International (Against)'].should == first_amount

		@another_expenditure = mock('another expenditure')
		@another_expenditure.stub(:payee).and_return("Evil Corp. International")
		@another_expenditure.stub(:support_or_oppose).and_return("O")
		@another_expenditure.stub(:amount).and_return(second_amount)

		IndependentExpenditure.stub(:candidate).and_return([@expenditure, @another_expenditure])

		@muckraker.load
		@muckraker.total_contributions_by_contributor['Evil Corp. International (Against)'].should == first_amount + second_amount
    end
end
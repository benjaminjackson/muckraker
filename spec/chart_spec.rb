require "#{File.dirname(__FILE__)}/spec_helper"

include SpecHelper

describe Muckraker, "when charting data with a single data set" do
	before do
		load_expenditures
	end
	it "should render the ERB template without error" do
		@muckraker.chart([@muckraker.top_payees])
	end
	it "should render the ERB template with the top payees" do
		chart = @muckraker.chart([@muckraker.top_payees])
		chart.should match(@expenditure.payee.normalize)
		chart.should match(@another_expenditure.payee.normalize)
		chart.should match(@top_expenditure.payee.normalize)
		chart.should match((@expenditure.amount / 100000).round.to_s)
		chart.should match((@another_expenditure.amount / 100000).round.to_s)
		chart.should match((@top_expenditure.amount / 100000).round.to_s)
	end
	it "should render the ERB template with the data set's title" do
		chart = @muckraker.chart([@muckraker.top_payees])
		chart.should match("Top Payees")
	end
end

describe Muckraker, "when charting data with multiple data sets" do
	before do
		load_expenditures
	end
	it "should render the ERB template without error" do
		@muckraker.chart([@muckraker.top_payees, @muckraker.top_payees('R')])
		@muckraker.chart([@muckraker.top_payees, @muckraker.top_payees('R'), @muckraker.top_payees('D')])
		@muckraker.chart([@muckraker.top_payees, @muckraker.top_payees("R"), @muckraker.top_payees("D"), @muckraker.top_payees("R", "S"), @muckraker.top_payees("D", "O"), @muckraker.top_payees("D", "S"), @muckraker.top_payees("R", "O")])
	end
	it "should render the template with the correct titles for the different data sets and no other titles" do
		chart = @muckraker.chart([@muckraker.top_payees, @muckraker.top_payees('R')])
		chart.should match(@muckraker.top_payees.title)
		chart.should match(@muckraker.top_payees('R').title)
		chart.should_not match(@muckraker.top_payees('R', 'S').title)
		chart.should_not match(@muckraker.top_payees('R', 'O').title)
		chart.should_not match(@muckraker.top_payees('D').title)
		chart.should_not match(@muckraker.top_payees('D', 'S').title)
		chart.should_not match(@muckraker.top_payees('D', 'O').title)
	end
end
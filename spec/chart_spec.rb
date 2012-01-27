require "#{File.dirname(__FILE__)}/spec_helper"

describe Muckraker, "when charting data" do
	before do
		load_expenditures
	end
	it "should render the ERB template without error" do
		@muckraker.chart([@muckraker.top_payees], "Test Chart")
	end
	it "should render the ERB template with the top payees" do
		chart = @muckraker.chart([@muckraker.top_payees], "Test Chart")
		chart.should match(@expenditure.payee.normalize)
		chart.should match(@another_expenditure.payee.normalize)
		chart.should match(@top_expenditure.payee.normalize)
		chart.should match(@expenditure.amount.to_s)
		chart.should match(@another_expenditure.amount.to_s)
		chart.should match(@top_expenditure.amount.to_s)
	end
end
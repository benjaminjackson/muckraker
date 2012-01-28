require "#{File.dirname(__FILE__)}/spec_helper"

include TestHelper

describe Muckraker, "when calculating the most-supported candidates" do
	before do
		load_expenditures
	end
end
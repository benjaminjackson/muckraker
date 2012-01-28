require "#{File.dirname(__FILE__)}/spec_helper"

include SpecHelper

describe Muckraker, "when calculating the most-supported candidates" do
	before do
		load_expenditures
	end
end
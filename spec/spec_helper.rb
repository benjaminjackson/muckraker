require 'rspec'
require 'muckraker'
require 'fileutils'
require 'factory_girl'
require "#{File.dirname(__FILE__)}/factories"

# Hack FactoryGirl to play nice with read-only attributes
module FactoryGirl
	class AttributeAssigner
		def object
			@evaluator.instance = build_class_instance
			build_class_instance.tap do |instance|
				attributes_to_set_on_instance.each do |attribute|
					if instance.respond_to?("#{attribute}=")
						instance.send("#{attribute}=", get(attribute))
					else
						instance.instance_variable_set("@#{attribute}", get(attribute))
					end
					@attribute_names_assigned << attribute
				end
			end
		end
	end
end

module SpecHelper

	API_KEY = '160748e2412352af46f3fe7c75cce5fd:15:63511996'
	DEFAULT_EXPENDITURE = 1000.0
	FIRST_EXPENDITURE = 100000.0
	LOWEST_EXPENDITURE = 50000.0
	TOP_EXPENDITURE = 70000000.0

	include CampaignCash

	def prepare_for_load
		@muckraker = Muckraker.new(API_KEY)
		@expenditure = FactoryGirl.build(:expenditure, :support_or_oppose => 'O', :amount => DEFAULT_EXPENDITURE)
		@candidate = FactoryGirl.build(:candidate)
		IndependentExpenditure.stub(:candidate).and_return([@expenditure])
		Candidate.stub(:state_chamber).and_return([])
		Candidate.stub(:state_chamber).with(:DE, 'house').and_return([@candidate])
	end

	def load_expenditures
		@muckraker = Muckraker.new(API_KEY)

		@expenditure = FactoryGirl.build(:expenditure, :support_or_oppose => 'O', :amount => FIRST_EXPENDITURE)
		@another_expenditure = FactoryGirl.build(:expenditure, :support_or_oppose => 'O', :amount => LOWEST_EXPENDITURE)
		@top_expenditure = FactoryGirl.build(:expenditure, :support_or_oppose => 'S', :amount => TOP_EXPENDITURE)

		@republican = FactoryGirl.build(:candidate, :party => 'REP', :name => 'Joe Schmoe')
		@democrat = FactoryGirl.build(:candidate, :party => 'DEM', :name => 'Jack Whack')

		IndependentExpenditure.stub(:candidate).with(@republican.id, 2012).and_return([@expenditure, @another_expenditure])
		IndependentExpenditure.stub(:candidate).with(@democrat.id, 2012).and_return([@top_expenditure])

		Candidate.stub(:state_chamber).and_return([])
		Candidate.stub(:state_chamber).with(:DE, 'house').and_return([@republican, @democrat])

		@another_expenditure.stub(:candidate).and_return(@republican.id)
		@expenditure.stub(:candidate).and_return(@republican.id)
		@top_expenditure.stub(:candidate).and_return(@democrat.id)

		@muckraker.load
	end

	def clear_cache
		FileUtils.rm_r(Muckraker::CACHE_DIR) if File.exists?(Muckraker::CACHE_DIR)
	end
end
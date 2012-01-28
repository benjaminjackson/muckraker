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

API_KEY = '160748e2412352af46f3fe7c75cce5fd:15:63511996'
DEFAULT_EXPENDITURE = 1000.0

include CampaignCash

def prepare_for_load
	@muckraker = Muckraker.new(API_KEY)
	@expenditure = mock('expenditure')
	@expenditure.stub(:payee).and_return("Evil Corp. International")
	@expenditure.stub(:support_or_oppose).and_return("O")
	@expenditure.stub(:amount).and_return(DEFAULT_EXPENDITURE)
	@candidate = mock('candidate')
	@candidate.stub(:id).and_return('P60003654')
	IndependentExpenditure.stub(:candidate).and_return([@expenditure])
	Candidate.stub(:state_chamber).and_return([])
	Candidate.stub(:state_chamber).with(:DE, 'house').and_return([@candidate])
end

def load_expenditures
	@muckraker = Muckraker.new(API_KEY)

	@expenditure = mock('expenditure')
	@expenditure.stub(:payee).and_return("Evil Corp. International")
	@expenditure.stub(:support_or_oppose).and_return("O")
	@expenditure.stub(:amount).and_return(FIRST_EXPENDITURE)

	@another_expenditure = mock('another expenditure')
	@another_expenditure.stub(:payee).and_return("Shameless Astroturf, Inc.")
	@another_expenditure.stub(:support_or_oppose).and_return("O")
	@another_expenditure.stub(:amount).and_return(SECOND_EXPENDITURE)

	@top_expenditure = mock('a really expensive expenditure')
	@top_expenditure.stub(:payee).and_return("Newscorp, Intl.")
	@top_expenditure.stub(:support_or_oppose).and_return("S")
	@top_expenditure.stub(:amount).and_return(TOP_EXPENDITURE)

	@republican = FactoryGirl.build(:candidate)
	@democrat = mock('democratic candidate', :id => 'P60003655', :party => 'DEM', :name => 'Jack Whack')

	IndependentExpenditure.stub(:candidate).with(@republican.id, 2012).and_return([@expenditure, @another_expenditure])
	IndependentExpenditure.stub(:candidate).with(@democrat.id, 2012).and_return([@top_expenditure])
	
	Candidate.stub(:state_chamber).and_return([])
	Candidate.stub(:state_chamber).with(:DE, 'house').and_return([@republican, @democrat])

	[@expenditure, @another_expenditure].each do |exp|
		exp.stub(:candidate).and_return(@republican.id)
	end
	@top_expenditure.stub(:candidate).and_return(@democrat.id)

	@muckraker.load
end

def clear_cache
	FileUtils.rm_r(Muckraker::CACHE_DIR) if File.exists?(Muckraker::CACHE_DIR)
end

clear_cache
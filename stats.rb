module Muckraker
	module Constants
		DEFAULT_LIMIT = 10
	end
end

class Campaign

	include Muckraker::Constants

	def self.most_supported
		campaigns_with_expenditures.sort do |first_campaign, second_campaign|
			first_campaign.total_expenditures(:support_or_oppose => 'S') <=> second_campaign.total_expenditures(:support_or_oppose => 'S')
		end.reverse[0..DEFAULT_LIMIT]
	end

	def self.most_opposed
		campaigns_with_expenditures.sort do |first_campaign, second_campaign|
			first_campaign.total_expenditures(:support_or_oppose => 'O') <=> second_campaign.total_expenditures(:support_or_oppose => 'O')
		end.reverse[0..DEFAULT_LIMIT]
	end

	def total_expenditures(options={})
		expenditures = IndependentExpenditure.all(:campaign => self)
		expenditures_with_options = expenditures
		if options[:support_or_oppose]
			expenditures_with_options = expenditures.all(:support_or_oppose => options[:support_or_oppose])
		end
		total = expenditures_with_options.inject(0) { |sum, exp| sum + exp.amount }
		sprintf("%0.2f", total).to_f
	end

	private

	def self.campaigns_with_expenditures
		IndependentExpenditure.all(:campaign => Campaign.all).map { |exp| exp.campaign }.sort.uniq
	end

end

class Committee

	include Muckraker::Constants

	def total_independent_expenditures support_or_oppose=nil
		return 0 if campaign.nil? # temporary! need to figure out why independent exp association is nil
		expenditures = campaign.independent_expenditures
		expenditures = expenditures.reject { |exp| exp.support_or_oppose != support_or_oppose } unless support_or_oppose.nil?
		expenditures.inject(0) { |sum, exp| sum + exp.amount }
	end
end
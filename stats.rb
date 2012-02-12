require 'dm-aggregates'

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

	def self.top_payees(party=nil, support_or_oppose=nil)
		payee_names = IndependentExpenditure.all(:fields => [:payee], :unique => true, :order => [:payee.asc])
		payee_names.sort { |a, b|
			amount_spent_on_payee(a.payee, party, support_or_oppose).to_f <=> amount_spent_on_payee(b.payee, party, support_or_oppose).to_f
		}.map { |exp| exp.payee }.reverse[0..DEFAULT_LIMIT]
	end

	def self.amount_spent_on_payee(payee, party=nil, support_or_oppose=nil)
		options = {}
		options[:campaign] = {:party => party } unless party.nil?
		options[:support_or_oppose] = support_or_oppose unless support_or_oppose.nil?
		IndependentExpenditure.sum(:amount, options.merge(:payee => payee))
	end

	def total_independent_expenditures support_or_oppose=nil
		return 0 if campaign.nil? # temporary! need to figure out why independent exp association is nil
		conditions = { :campaign => campaign }
		conditions[:support_or_oppose] = support_or_oppose unless support_or_oppose.nil?
		IndependentExpenditure.sum(:amount, conditions)
	end

end
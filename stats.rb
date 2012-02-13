require 'dm-aggregates'

module Muckraker
	module Constants
		DEFAULT_LIMIT = 10
	end
end

class Campaign

	include Muckraker::Constants

	def self.money_magnets
		campaigns_with_expenditures.sort do |first_campaign, second_campaign|
			first_campaign.total_expenditures <=>
			second_campaign.total_expenditures
		end.reverse[0..DEFAULT_LIMIT]
	end

	def self.most_supported
		campaigns_with_expenditures.sort do |first_campaign, second_campaign|
			first_campaign.total_expenditures(:support_or_oppose => 'S') + first_campaign.total_disbursements.to_i <=>
			second_campaign.total_expenditures(:support_or_oppose => 'S') + second_campaign.total_disbursements.to_i
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

	def self.top_spenders
		committee_ids = IndependentExpenditure.all(:fields => [:committee_id], :unique => true, :order => [:committee_id.asc]).map { |e| e.committee_id}
		Committee.all(:id => committee_ids).sort { |a, b|
			IndependentExpenditure.sum(:amount, :committee => a) <=> IndependentExpenditure.sum(:amount, :committee => b)
		}.reverse[0..DEFAULT_LIMIT]
	end

	def top_campaigns
		campaign_ids = IndependentExpenditure.all(:committee => self).all(:fields => [:campaign_id], :unique => true, :order => [:campaign_id.asc]).map { |e| e.campaign_id}
		Campaign.all(:id => campaign_ids).sort { |a, b|
			IndependentExpenditure.sum(:amount, :campaign => a, :committee => self).to_i <=> IndependentExpenditure.sum(:amount, :campaign => b, :committee => self).to_i
		}.reverse[0..DEFAULT_LIMIT]
	end

	def expenditures_supporting campaign
		IndependentExpenditure.sum(:amount, :campaign => campaign, :committee => self, :support_or_oppose => 'S')
	end

	def expenditures_opposing campaign
		IndependentExpenditure.sum(:amount, :campaign => campaign, :committee => self, :support_or_oppose => 'O')
	end

	def total_independent_expenditures support_or_oppose=nil
		IndependentExpenditure.sum(:amount, :committee => self)
	end

end
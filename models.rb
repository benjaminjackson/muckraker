require 'data_mapper'
require 'dm-timestamps'

class Campaign
	include DataMapper::Resource

	has 1, :committee
	has n, :independent_expenditures

	property :id, Serial
	property :name, String
	property :district, Integer
	property :party, String
	property :office, String
	property :state, String
	property :status, String
	property :total_receipts, Decimal
	property :total_contributions, Decimal
	property :total_from_individuals, Decimal
	property :total_from_pacs, Decimal
	property :candidate_loans, Decimal
	property :total_disbursements, Decimal
	property :total_refunds, Decimal
	property :debts_owed, Decimal
	property :begin_cash, Decimal
	property :end_cash, Decimal
	property :created_at, DateTime
	property :updated_at, DateTime
end

class IndependentExpenditure
	include DataMapper::Resource

	belongs_to :committee
	belongs_to :campaign

	property :id, Serial
	property :amount, Decimal
	property :payee, String
	property :support_or_oppose, String
	property :purpose, String
	property :transaction_id, String
	property :date_received, Date
	property :created_at, DateTime
	property :updated_at, DateTime
end

class Committee
	include DataMapper::Resource

	belongs_to :campaign
	has n, :independent_expenditures

	property :id, Serial
	property :name, String
	property :state, String
	property :district, Integer
	property :party, String
	property :super_pac, Boolean
	property :sponsor_name, String
	property :filing_frequency, String
	property :interest_group, String
	property :committee_type, String
	property :designation, String
	property :total_receipts, Decimal
	property :total_receipts, Decimal
	property :total_contributions, Decimal
	property :total_from_individuals, Decimal
	property :total_from_pacs, Decimal
	property :candidate_loans, Decimal
	property :total_disbursements, Decimal
	property :debts_owed, Decimal
	property :begin_cash, Decimal
	property :end_cash, Decimal
end
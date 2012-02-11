require 'data_mapper'
require 'dm-timestamps'

class Campaign
	include DataMapper::Resource

	has 1, :committee
	has n, :independent_expenditures

	property :id, Serial
	property :remote_id, String
	property :name, Text
	property :district, Integer
	property :party, String
	property :office, String
	property :state, String
	property :status, String
	property :total_receipts, Float
	property :total_contributions, Float
	property :total_from_individuals, Float
	property :total_from_pacs, Float
	property :candidate_loans, Float
	property :total_disbursements, Float
	property :total_refunds, Float
	property :debts_owed, Float
	property :begin_cash, Float
	property :end_cash, Float
	property :created_at, DateTime
	property :updated_at, DateTime
end

class IndependentExpenditure
	include DataMapper::Resource

	belongs_to :committee, :required => false
	belongs_to :campaign

	property :id, Serial
	property :amount, Float
	property :payee, Text
	property :support_or_oppose, String
	property :purpose, Text
	property :transaction_id, String
	property :date_received, Date
	property :created_at, DateTime
	property :updated_at, DateTime
end

class Committee
	include DataMapper::Resource

	belongs_to :campaign, :required => false
	has n, :independent_expenditures

	property :id, Serial
	property :remote_id, String
	property :name, Text
	property :state, String
	property :district, Integer
	property :party, String
	property :super_pac, Boolean
	property :sponsor_name, Text
	property :filing_frequency, String
	property :interest_group, String
	property :committee_type, String
	property :designation, String
	property :total_receipts, Float
	property :total_contributions, Float
	property :total_from_individuals, Float
	property :total_from_pacs, Float
	property :candidate_loans, Float
	property :total_disbursements, Float
	property :debts_owed, Float
	property :begin_cash, Float
	property :end_cash, Float
end
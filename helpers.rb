require 'rubygems'
require 'campaign_cash'
require 'yaml'
require 'fileutils'
require 'titlecase'
require 'erb'

class String
    # normalize against differences in names (e.g. , LLC vs. just LLC)
    def normalize
        downcase.titlecase.gsub(/[,]/i, '')
    end
    # unused for now as it messes up Google charts and there's no option for currency
    def to_currency
        reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
    end
end

module Helpers
	def candidate_party_color candidate
		return "#BE2500" if  candidate.party == "REP"
		return "#2960D0" if  candidate.party == "DEM"
		"#BE622A"
	end
end


helpers Helpers
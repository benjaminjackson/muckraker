module Muckraker::Helpers
	def candidate_party_color candidate
		return "#BE2500" if  candidate.party == "REP"
		return "#2960D0" if  candidate.party == "DEM"
		"#BE622A"
	end
end


helpers Muckraker::Helpers
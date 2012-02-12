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

    def truncate(text, length=20, end_string = ' ...')
        text[0..(length-1)] + (text.length > length ? end_string : '')
    end

    def truncate_words(text, length=25, end_string = ' ...')
        text.split do
            words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
        end
    end

end

module AppHelpers

    PAGE_INFO = YAML::load(File.open("config/page_info.yml").read)

    def info_for_page
        PAGE_INFO.each do |page|
            return page['info'] if request.path_info.match(page['match'])
        end
        return nil
    end

end

helpers Helpers
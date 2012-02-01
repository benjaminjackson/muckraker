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

class Muckraker

	include CampaignCash

    DEFAULT_LIMIT = 10
    US_STATES = [:AL, :AK, :AZ, :AR, :CA, :CO, :CT, :DE, :FL, :GA, :HI, :ID, :IL, :IN, :IA, :KS, :KY, :LA, :ME, :MD,
                 :MA, :MI, :MN, :MS, :MO, :MT, :NE, :NV, :NH, :NJ, :NM, :NY, :NC, :ND, :OH, :OK, :OR, :PA, :RI, :SC,
                 :SD, :TN, :TX, :UT, :VT, :VA, :WA, :WV, :WI, :WY]

    CACHE_DIR = File.expand_path "~/.muckraker/cache"
    CANDIDATES_CACHE_FILENAME = 'candidates.yaml'
    EXPENDITURES_CACHE_FILENAME = 'expenditures.yaml'

    TEMPLATE_FILENAME = 'template.html.erb'

    attr_accessor :cache, :candidates, :expenditures, :payees

    def initialize(api_key)
   		Base.api_key = api_key
    end

    def cache=cache
        @cache = cache
        if cache
            FileUtils.mkdir_p CACHE_DIR
        end
    end

    def load
        if cache && has_cached_data?
            load_from_cache
        else
            load_candidates
            load_expenditures
        end
        candidates_with_no_committees = @candidates.select { |c| c.committee_id.nil? }.map { |c| c.id }
        @candidates.reject! { |c| c.committee_id.nil? }
        @expenditures.reject! { |exp| candidates_with_no_committees.include? exp.candidate }

        generate_candidate_id_map
    end

    def chart data_sets
        data_sets = [data_sets] unless data_sets.is_a?(Array)
        @data_sets = data_sets
        template = File.open(File.join(File.dirname(__FILE__), TEMPLATE_FILENAME)).read
        return ERB.new(template).result(binding)
    end

    # party is one of 'REP' or 'DEM'
    # support_or_oppose is one of 'O' or 'S'

    def top_payees party=nil, support_or_oppose=nil, limit=DEFAULT_LIMIT
        data_set = top_values "Top Payees", party, support_or_oppose, limit do |exp|
            exp.payee.normalize
        end
        data_set.legend = data_set.legend.map { |payee| payee.titlecase }
        data_set.chart_type = "BarChart"
        data_set
    end

    def top_committees party=nil, support_or_oppose=nil, limit=DEFAULT_LIMIT
        data_set = top_values "Top Committees", party, support_or_oppose, limit do |exp|
            exp.committee_name.normalize
        end
        data_set.legend = data_set.legend.map { |committee_name| committee_name.titlecase }
        data_set.chart_type = "BarChart"
        data_set

    end

    def top_states party=nil, support_or_oppose=nil, limit=US_STATES.length
        data_set = top_values "Top States", party, support_or_oppose, limit do |exp|
            exp.state
        end
        # strip expenses with no state declared
        if data_set.legend.first.empty?
            data_set.legend.shift
            data_set.data.shift
        end
        data_set.legend = data_set.legend.map { |state| "US-#{state.upcase}" }
        data_set.chart_type = "GeoMap"
        data_set

    end

    def top_values title, party=nil, support_or_oppose=nil, limit=DEFAULT_LIMIT
        filtered_expenditures = @expenditures
        unless support_or_oppose.nil?
            filtered_expenditures = filtered_expenditures.reject { |exp| exp.support_or_oppose != support_or_oppose }
        end
        unless party.nil?
            filtered_expenditures = restrict_to_party(filtered_expenditures, party)
        end

        payee_names, data = sort_expenditures(filtered_expenditures) do |exp|
            yield(exp)
        end
        columns = { :names => ['Payee', 'Amount'], :types => ['string', 'number'] }
        title += " #{support_or_oppose == 'O' ? 'Opposing' : 'Supporting'}" if support_or_oppose
        title += " #{party == 'REP' ? 'Republicans' : 'Democrats'}" if party
        DataSet.new(title, payee_names[0...limit], data[0...limit], columns)
    end

    def top_payees_for_candidate candidate_id, support_or_oppose=nil, limit=DEFAULT_LIMIT
        top_values_for_candidate "Top Payees ", candidate_id, support_or_oppose, limit do |exp|
            exp.payee.normalize
        end
    end

    def top_committees_for_candidate candidate_id, support_or_oppose=nil, limit=DEFAULT_LIMIT
        top_values_for_candidate "Top Committees ", candidate_id, support_or_oppose, limit do |exp|
            exp.committee_name.normalize
        end
    end

    def top_values_for_candidate title, candidate_id, support_or_oppose=nil, limit=DEFAULT_LIMIT
        candidate = @candidate_id_map[candidate_id]
        filtered_expenditures = []
        @expenditures.each do |exp|
            if exp.candidate == candidate_id
                filtered_expenditures << exp
            end
        end
        if support_or_oppose
            filtered_expenditures.reject! { |exp| exp.support_or_oppose != support_or_oppose }
        end

        payee_names, data = sort_expenditures(filtered_expenditures) do |exp|
            yield(exp)
        end
        columns = { :names => ['Payee', 'Amount'], :types => ['string', 'number'] }
        title += "#{support_or_oppose == 'O' ? 'Opposing' : 'Supporting'} " if support_or_oppose
        title += candidate.name + " (#{candidate.party}, #{candidate.office}) "
        DataSet.new(title, payee_names[0...limit], data[0...limit], columns)
    end

    def top_supported_candidates party=nil, limit=DEFAULT_LIMIT
        top_candidates 'S', party, limit
    end

    def top_opposed_candidates party=nil, limit=DEFAULT_LIMIT
        top_candidates 'O', party, limit
    end

    private

    def top_candidates support_or_oppose, party=nil, limit=DEFAULT_LIMIT
        filtered_expenditures = @expenditures
        unless party.nil?
            filtered_expenditures = restrict_to_party(filtered_expenditures, party)
        end
        filtered_expenditures = filtered_expenditures.select { |exp| exp.support_or_oppose == support_or_oppose }
        candidate_names, data = sort_expenditures(filtered_expenditures) do |exp|
            candidate = @candidate_id_map[exp.candidate]
            candidate.name + " (#{candidate.party}, #{candidate.office})"
        end
        candidate_ids = candidate_names.map do |candidate_name|
            c = @candidates.find { |c| candidate_name.include?(c.name) && candidate_name.include?(c.office) }
            c.id
        end
        columns = { :names => ['Candidate Name', 'Amount Spent'], :types => ['string', 'number'] }
        title = "Most "
        title += " #{support_or_oppose == 'O' ? 'Opposed' : 'Supported'} "
        title += "#{party.nil? ? '' : party + " "}Candidates: "
        data_set = DataSet.new(title, candidate_names[0...limit], data[0...limit], columns, candidate_ids[0...limit])
        data_set.chart_type = "BarChart"
        data_set
    end

    def restrict_to_party expenditures, party
        expenditures.reject do |exp|
            candidate = @candidate_id_map[exp.candidate]
            candidate.party != party
        end
    end

    def load_from_cache
        @candidates = YAML::load File.open(File.join(CACHE_DIR, CANDIDATES_CACHE_FILENAME)).read
        @expenditures = YAML::load File.open(File.join(CACHE_DIR, EXPENDITURES_CACHE_FILENAME)).read
    end

    def generate_candidate_id_map
        @candidate_id_map = {}
        @candidates.each do |candidate|
            @candidate_id_map[candidate.id] = candidate
        end
    end

    def load_candidates
        # puts "Loading congressional candidates..."
    	@candidates = US_STATES.map do |state|
            # puts "Loading candidates for #{state}..."
  			Candidate.state_chamber(state, 'senate') + Candidate.state_chamber(state, 'house')
		end.flatten
        # puts "Loading presidential candidates..."
        # @candidates += President.summary
        if cache
            File.open(File.join(CACHE_DIR, CANDIDATES_CACHE_FILENAME), 'w') do |f|
                f.write YAML::dump(@candidates)
            end
        end
    end

    def has_cached_data?
        [CANDIDATES_CACHE_FILENAME, EXPENDITURES_CACHE_FILENAME].each do |filename|
            return false unless File.exists?(File.join(CACHE_DIR, filename))
        end
        true
    end

    def load_expenditures
        @expenditures = []
        # puts "Loading expenditures"
        @candidates.each_with_index do |candidate, index|
            # puts "Loading expenditures for candidate #{index} of #{@candidates.length}: #{candidate.name}, #{candidate.office}..."
            load_expenditures_for_candidate(candidate.id)
        end
        if cache
            File.open(File.join(CACHE_DIR, EXPENDITURES_CACHE_FILENAME), 'w') do |f|
                f.write YAML::dump(@expenditures)
            end
        end
    end

    def load_expenditures_for_candidate(candidate_id, year=2012)
		candidate_expenditures = IndependentExpenditure.candidate(candidate_id, year)
    	@expenditures << candidate_expenditures
        @expenditures.flatten!
    end

    def sort_expenditures expenditures
        results = {}
        expenditures.each do |exp|
            key = yield(exp)
            results[key] ||= 0
            # Data from API must be multiplied by 10, not sure why
            results[key] += exp.amount
        end
        keys = results.keys.sort do |a, b|
          results[b] <=> results[a]
        end
        data = []
        keys.each do |key|
            data << (results[key] * 10).floor
        end
        [keys, data]
    end

end

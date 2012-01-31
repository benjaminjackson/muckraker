## DESCRIPTION: 

Simple ruby wrapper around the NYTimes/campaign_cash library, which is itself a simple ruby wrapper around the [New York Times Campaign Finance API](http://developer.nytimes.com/docs/read/campaign_finance_api).

## INSTALLATION:

    gem install muckraker

## USAGE:

### Initializing

    m = Muckraker.new("API_KEY")
    m.cache = true 
    m.load
    
Please make sure to set `cache` to `true` for now. Caching will be enabled by default shortly to avoid hitting rate limits when loading all expenditures.
    
### Top Payees
    
    # List of top payees for both parties, supporting and opposing
    m.top_payees.legend

    # Data for the same
    m.top_payees.data
    
    # Top payees both supporting and opposing Republican candidates
    m.top_payees("R") 

    # Top payees supporting Democratic candidates
    m.top_payees("D", "S"), 
    
    # Top payees supporting/opposing each candidate
    supporting_payees = m.candidates.map { |candidate| m.top_payees_for_candidate(candidate.id, "S") }
    supporting_payees = m.candidates.map { |candidate| m.top_payees_for_candidate(candidate.id, "O") }


### Charts

    # Chart the top payees supporting Democratic candidates as a pie chart
    m.chart(m.top_payees("D", "S"))
    
### Chart Types

    # Chart the above as a bar chart
    data_set = m.top_payees("D", "S")
    data_set.chart_type = "BarChart"
    m.chart(data_set)
    
### Chaining Calls Together for Fun & Profit
    
    # Chart top supported and opposed candidates and top payees for each
    data_sets = []
    {'S' => m.top_supported_candidates, 'O' => m.top_opposed_candidates}.each_pair do |support_or_oppose, data_set|
        data_sets << data_set
        data_set.legend_ids.each_with_index do |candidate_id, i|
            data_sets << m.top_payees_for_candidate(candidate_id, support_or_oppose)
        end
    end
    m.chart(data_sets)

### Presidential Candidates

    # Chart top payees supporting and opposing all presidential candidates
    data_sets = []
    m.candidates.select { |c| c.office == 'president' }.each do |c|
        data_sets << m.top_committees_for_candidate(c.id, 'S')
        data_sets << m.top_committees_for_candidate(c.id, 'O')
    end
    m.chart(data_sets)

### States

    # Chart top states with spending for republican candidates and opposing democratic candidates
    data_sets = [m.top_states('R', 'S'), m.top_states('D', 'O')]
    m.chart(data_sets)

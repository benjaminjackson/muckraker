SimpleNavigation::Configuration.run do |navigation|
	navigation.selected_class = 'active'

    navigation.items do |primary|
		primary.dom_class = 'nav nav-list'
	    primary.item :committee_expenditures_by_campaign, 'Expenditures by Campaign', params[:id], :highlights_on => /\/committee\/[0-9]+/
	    primary.item :committee_expenditures_by_purpose, 'Expenditures by Purpose', params[:id] + '/purpose', :highlights_on => /\/committee\/[0-9]+\/purpose/
    end
end

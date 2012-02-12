SimpleNavigation::Configuration.run do |navigation|
	navigation.selected_class = 'active'

    navigation.items do |primary|
		primary.dom_class = 'nav'
	    primary.item :campaigns, 'Campaigns', '/'
	    primary.item :committees, 'Committees', '/committees'
	    primary.item :payees, 'Payees', '/payees' do |secondary|
			secondary.dom_class = 'nav nav-list'
	    	secondary.item :all, "All Campaigns", '/payees'
	    	secondary.item :all, "Democrat Campaigns", '/payees/dem'
	    	secondary.item :all, "Republican Campaigns", '/payees/rep'
	    end
	    primary.item :about, 'About', '#about'
	    primary.item :contact, 'Contact', '#contact'
    end
end

SimpleNavigation::Configuration.run do |navigation|
	navigation.selected_class = 'active'

    navigation.items do |primary|
		primary.dom_class = 'nav'
	    primary.item :campaigns, 'Campaigns', '/'
	    primary.item :committees, 'Committees', '/committees'
	    primary.item :payees, 'Payees', '/payees' do |secondary|
			secondary.dom_class = 'dropdown-menu'
	    	secondary.item :all, "All Parties", '/payees/'
	    	secondary.item :all, "Democrat", '/payees/dem'
	    	secondary.item :all, "Republican", '/payees/rep'
	    end
	    primary.item :about, 'About', '#about'
	    primary.item :contact, 'Contact', '#contact'
    end
end

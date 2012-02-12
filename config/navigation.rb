SimpleNavigation::Configuration.run do |navigation|
	navigation.selected_class = 'active'

    navigation.items do |primary|
		primary.dom_class = 'nav'
	    primary.item :campaigns, 'Campaigns', '/'
	    primary.item :committees, 'Committees', '/committees'
	    primary.item :payees, 'Payees', '/payees'
	    primary.item :about, 'About', '#about'
	    primary.item :contact, 'Contact', '#contact'
    end
end

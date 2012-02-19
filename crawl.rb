require 'rubygems'
require 'anemone'

50.times do
	Anemone.crawl("http://muckraker.heroku.com/") do |anemone|
	  anemone.focus_crawl do |page|
		  page.links.select { |link| link.to_s.match(/\/%23/).nil?	}
	  end
	  anemone.on_every_page do |page|
	      puts page.url
	  end
	end
end

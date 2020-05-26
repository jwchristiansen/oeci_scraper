module Prompt
	def header
		puts ''
		puts 'OECI SCRAPER'
		puts ''
	end

	def credentials
		if ENV['OECI_USERNAME'] && ENV['OECI_PASSWORD']
			@@username = ENV['OECI_USERNAME']
			@@password = ENV['OECI_PASSWORD']
		else
			print 'OECI Username: '
			@@username = gets

			print 'OECI Password: '
			@@password = gets
		end
	end

	def date
		print 'Date [Format YYYY-MM-DD]: '
		@@search_date = Date.parse gets
		puts ''
	end

	def counties(counties)
		puts 'Counties: '
		puts counties.join(', ')
		puts '(from: app/counties.rb)'
		puts ''
	end

	def starting_search
		puts 'STARTING SEARCH...'
		puts ''
	end
end

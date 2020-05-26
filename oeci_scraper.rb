# initialize
require_relative 'config/initializers/initializer.rb'

# create a file to store output
output_file = File.new("output/#{DateTime.now}", "w")

# display prompts
Prompt.header
Prompt.credentials
Prompt.counties(@counties)
Prompt.date
Prompt.starting_search

# format date for OECI
# see: https://apidock.com/ruby/DateTime/strftime
@oeci_date = @@search_date.strftime("%-m/%-d/%Y")

# loop through counties per method specified in initializer.
@counties.each do |county|

	# display each county name so user sees county being scraped.
	puts "***#{county}***"
	puts ''

	# login to OECI
	# see: http://watir.com/guides/chrome/
	browser = Watir::Browser.new :chrome, headless: true
	browser.goto 'https://publicaccess.courts.oregon.gov/PublicAccessLogin/Login.aspx'
	browser.text_field(name: 'UserName').set @@username
	browser.text_field(name: 'Password').set @@password
	browser.button(name: 'SignOn').click

	# select county
	browser.select_list(id: "sbxControlID2").select("#{county}")

	# limit search to civil, family, probate, and tax departments
	# note: this feature could be extended to allow users to select different
	# court departments
	browser.link(text: "Search Civil, Family, Probate and Tax Court Case Records").click

	# specify date range and submit query to OECI
	browser.select_list(id: "SearchBy").select("Date Filed")
	browser.text_field(name: 'DateFiledOnAfter').set "#{@oeci_date}"
	browser.text_field(name: 'DateFiledOnBefore').set "#{@oeci_date}"
	browser.button(type: 'submit').click

	# create Nokogiri page from OECI results
	page = Nokogiri::HTML.parse(browser.html)

	# set parser default position to table row 2 (this is where the actual case
	# data begins appearing in the HTML table on OECI)
	row = 2

	# set counters
	count_total = 0
	count_scraped = 0

	# go through each row on OECI that has contents
	while page.xpath("/html/body/table[4]/tbody/tr[#{row}]/td[2]").length > 0

		# using nokogiri, scrape contents of each row into a hash
		# re _xpaths_ : https://nokogiri.org/tutorials/searching_a_xml_html_document.html
		# re _gsub_ : https://apidock.com/ruby/String/gsub
		# re _strptime_ : https://apidock.com/ruby/DateTime/strptime/class
		matter = Hash.new
		matter[:oeci_number] = page.xpath("/html/body/table[4]/tbody/tr[#{row}]/td[1]/a").text.gsub(/\s+/, ' ')
		matter[:oeci_caption] = page.xpath("/html/body/table[4]/tbody/tr[#{row}]/td[2]").text.gsub(/\s+/, ' ')
		matter[:oeci_county] = county
		matter[:oeci_filing_date] = Date.strptime(page.xpath("/html/body/table[4]/tbody/tr[#{row}]/td[3]/div[1]").text.gsub(/\s+/, ' '), '%m/%d/%Y')
		matter[:oeci_type] = page.xpath("/html/body/table[4]/tbody/tr[#{row}]/td[4]/div[1]").text.gsub(/\s+/, ' ')
		matter[:oeci_status] = page.xpath("/html/body/table[4]/tbody/tr[#{row}]/td[4]/div[2]").text.gsub(/\s+/, ' ')

		# filter out case types with CaseTypes model
		# note: this section would benefit from further refactoring to make
		# it easier to configure case types
		if !@case_types.include? matter[:oeci_type]

			# filter out cases where the caption includes a party from our Parties
			# model
			# note: you could improve precision here by digging into the docket
			if !@parties.any? {|omitted_party| matter[:oeci_caption].include?(omitted_party)}

				# send json to file we created at the beginning
				output_file.puts("#{matter.to_json}")

				# print out matter numbers and captions in terminal
				puts "#{matter[:oeci_number]} - #{matter[:oeci_caption]}"

				# increase count of scraped matters
				count_scraped += 1
			end
		end

		# move to next row
		row += 1

		# add each matter to total count
		count_total += 1
	end

	# close browser
	browser.close

	# print county-specific counts
	puts '==============='
	puts "Total: #{count_total}; Scraped: #{count_scraped}"
	puts ''
end

# close json file
output_file.close

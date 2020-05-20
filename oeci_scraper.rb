require_relative 'config/initializers/initializer.rb'
include Prompt

output_file = File.new("output/#{DateTime.now}", "w")

Prompt.header
Prompt.credentials
Prompt.counties(@counties)
Prompt.date

matters = Hash.new
matters[:count] = 0
matters[:filing_date] = @@search_date

day = @@search_date[5..6]
month = @@search_date[8..9]
year = @@search_date[0..3]
@oeci_date = "#{day}/#{month}/#{year}"

Prompt.starting_search

@counties.each do |county|

	puts "***#{county}***"
	puts ''

	#login to OECI
	browser = Watir::Browser.new :chrome, headless: true
	browser.goto 'https://publicaccess.courts.oregon.gov/PublicAccessLogin/Login.aspx'
	browser.text_field(name: 'UserName').set @@username
	browser.text_field(name: 'Password').set @@password
	browser.button(type: 'submit').click

	# Select county
	browser.select_list(id: "sbxControlID2").select("#{county}")

	# Review civil cases only
	browser.link(text: "Search Civil, Family, Probate and Tax Court Case Records").click

	# Enter date range
	browser.select_list(id: "SearchBy").select("Date Filed")
	browser.text_field(name: 'DateFiledOnAfter').set "#{@oeci_date}"
	browser.text_field(name: 'DateFiledOnBefore').set "#{@oeci_date}"
	browser.button(type: 'submit').click

	page = Nokogiri::HTML.parse(browser.html)

	i = 2
	j = 0

	while page.xpath("/html/body/table[4]/tbody/tr[#{i}]/td[2]").length > 0

		matter_number = page.xpath("/html/body/table[4]/tbody/tr[#{i}]/td[1]/a").text.gsub(/\s+/, ' ')
		matter_caption = page.xpath("/html/body/table[4]/tbody/tr[#{i}]/td[2]").text.gsub(/\s+/, ' ')
		matter_filing_date = page.xpath("/html/body/table[4]/tbody/tr[#{i}]/td[3]/div[1]").text.gsub(/\s+/, ' ')
		matter_type = page.xpath("/html/body/table[4]/tbody/tr[#{i}]/td[4]/div[1]").text.gsub(/\s+/, ' ')
		matter_status = page.xpath("/html/body/table[4]/tbody/tr[#{i}]/td[4]/div[2]").text.gsub(/\s+/, ' ')

		if !@case_types.include? matter_type
			if !@parties.any? {|omitted_party| matter_caption.include?(omitted_party)}

				matter = Hash.new
				matter[:number] = matter_number
				matter[:caption] = matter_caption
				matter[:county] = county
				matter[:filing_date] = Date.strptime(matter_filing_date, '%m/%d/%Y')
				matter[:oeci_type] = matter_type

				output_file.puts("#{matter.to_json}")
				puts "#{matter[:number]} - #{matter[:caption]}"
			end
		end

		i += 1
		j += 1
	end
	browser.close

	matters[:county] = county
	matters[:count] = j

	puts '==============='
	puts "Total: #{matters[:count]}"
	puts ''
end

output_file.close

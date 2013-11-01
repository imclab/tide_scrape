require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'date'

File.open('tide_scrape.html', 'w') do |f|

	page = Nokogiri::HTML(open("http://magicseaweed.com/Newquay-Fistral-North-Surf-Report/1/"))
	surfspot = page.css("title").text.gsub!('Surf Report, Surf Forecast and Live Surf Webcams', '').strip
	tide_table = page.css("table[class~='msw-tide-table']")
	light_table = page.css("table[class~='msw-tide-stable']")

	first_peak = tide_table.css("tr")[0]
	second_peak = tide_table.css("tr")[1]
	third_peak = tide_table.css("tr")[2]
	fourth_peak = tide_table.css("tr")[3]

	first_light = light_table.css("tr")[0]
	sunrise = light_table.css("tr")[1]
	sunset = light_table.css("tr")[2]
	last_light = light_table.css("tr")[3]

	tide = {
		first_peak => {
						:time =>   first_peak.css("td")[1].text.strip,
						:height => first_peak.css("td")[2].text.strip   },
		second_peak => {
						:time =>   second_peak.css("td")[1].text.strip,
						:height => second_peak.css("td")[2].text.strip    },
		third_peak => {
						:time =>   third_peak.css("td")[1].text.strip,
						:height => third_peak.css("td")[2].text.strip  },
		fourth_peak => {
						:time =>   fourth_peak.css("td")[1].text.strip,
						:height => fourth_peak.css("td")[2].text.strip   }
	}

	light = {
		:first_light => first_light.css("td")[1].text.strip,
		:sunrise => 	sunrise.css("td")[1].text.strip,
		:sunset => 		sunset.css("td")[1].text.strip,
		:last_light => 	last_light.css("td")[1].text.strip
	}

	def height_to_f(height)
		height.gsub('ft','').to_f.round(2)
	end

	def get_av_height(tide)
		average_height = 0
		tide.each do |k,v|
			average_height += height_to_f(v[:height])
		end
		average_height = average_height/tide.length
	end


def high_or_low(height,tide)

	if height_to_f(height) > get_av_height(tide)
		return "high"
	else
		return "low"
	end

end

def time_to_f(time)

	if !time.is_a?(Numeric)
		time = time.downcase

		if time.end_with?("pm")
			time.gsub!('pm','')
			modifier = 50
		else
			time.gsub!('am','')
			modifier = 0
		end
		time_a = time.split(':')

		h_percentage = (100.0/24.0)*(time_a[0].to_f)
		m_percentage = (100.0/24.0/60.0)*(time_a[1].to_f)

		return (h_percentage + m_percentage + modifier).round(2)
	end
		return time
end


	f_light = time_to_f(light[:first_light])
	s_rise = time_to_f(light[:sunrise]) - time_to_f(light[:first_light])
	s_set = (100 - time_to_f(light[:sunset])) - (100 - time_to_f(light[:last_light]))
	l_light = 100 -time_to_f(light[:last_light])

	daylight = 100 - f_light - s_rise - s_set - l_light

	f.write("

		<link rel='stylesheet' type='text/css' href='./style.css' />
		<div> 

		Tide Table for: #{surfspot} 
		<br><br> 
		First light = #{light[:first_light]} 
		<br> 
		Sunrise = #{light[:sunrise]} 
		<br> 
		Sunset = #{light[:sunset]} 
		<br> 
		Last light = #{light[:last_light]} 
		<br> 


		<br> 
		First #{high_or_low(tide[first_peak][:height],tide)} is at #{tide[first_peak][:time]} and is #{tide[first_peak][:height]} high
		<br> 
		First #{high_or_low(tide[second_peak][:height],tide)} is at #{tide[second_peak][:time]} and is #{tide[second_peak][:height]} high
		<br> 
		Second #{high_or_low(tide[third_peak][:height],tide)} is at #{tide[third_peak][:time]} and is #{tide[third_peak][:height]} high
		<br> 
		Second #{high_or_low(tide[fourth_peak][:height],tide)} is at #{tide[fourth_peak][:time]} and is #{tide[fourth_peak][:height]} high
		<br> 


		</div>\n\n<br>
			<div class='daybar'><!--
			--><div class='first_light bar' style='width:#{f_light}%'></div><!--
			--><div class='sunrise bar' style='width:#{s_rise}%'></div><!--
			--><div class='day bar' style='width:#{daylight}%'></div><!--
			--><div class='sunset bar' style='width:#{s_set}%'></div><!--
			--><div class='last_light bar' style='width:#{l_light}%'></div><!--
			--></div>

		")


end

 
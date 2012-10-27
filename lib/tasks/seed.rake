require 'nokogiri'
require 'open-uri'
require 'restclient'

STATIONS_URL = "http://www.ratb.ro/statii.php"
USER_AGENT = 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.2 (KHTML, like Gecko) Safari/125.8'
STATIONS_JSON = File.join Rails.root.to_s, 'db', 'fixtures', 'stations.json'

def station_buses(station_name)
  RestClient.post URL, {'tlin6' => station_name} do |f|
    dom = Nokogiri::HTML f
    puts dom.css('table')[2].css('tr')[1].css('td')[1]
  end
end
 
namespace :seed do
  task :create_stations_json => :environment do
    open STATIONS_URL, "User-Agent" => USER_AGENT do |f|
      dom = Nokogiri::HTML f
      stations = dom.css('select[name=tlin6]').css('option[value!="0"]').collect{|x| x[:value]}

      f = open(STATIONS_JSON, 'w')
      f.write JSON.dump stations
      f.close
    end
  end
end

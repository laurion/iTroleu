require 'nokogiri'
require 'open-uri'
require 'restclient'

STATIONS_URL = "http://www.ratb.ro/statii.php"
USER_AGENT = 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.2 (KHTML, like Gecko) Safari/125.8'
STATIONS_JSON = File.join Rails.root.to_s, 'db', 'fixtures', 'stations.json'

def station_buses(station_name)
  RestClient.post STATIONS_URL, {'tlin6' => station_name} do |f|
    dom = Nokogiri::HTML f
    return dom.css('table')[3].css('tr')[1].css('td')[1].text
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

  task :create_buses_json => :environment do
    all_buses = []
    open(STATIONS_JSON, 'r') do |file|
      stations = JSON.load file.read
      stations.each do |station|
        buses = station_buses station
        all_buses <<= buses.split(',')
      end
    end

    open(BUSES_JSON, 'w') do |file|
      f.write JSON.dump all_buses
      f.close
    end
  end
end

require 'nokogiri'
require 'open-uri'
require 'restclient'

STATIONS_URL = "http://www.ratb.ro/statii.php"
USER_AGENT = 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.2 (KHTML, like Gecko) Safari/125.8'
STATIONS_JSON = File.join Rails.root.to_s, 'db', 'fixtures', 'stations.json'
BUSES_JSON = File.join Rails.root.to_s, 'db', 'fixtures', 'buses.json'

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
    all_buses = {}
    open(STATIONS_JSON, 'r') do |file|
      stations = JSON.load file.read
      stations.each do |station|
        puts "Computing for station #{station}"
        buses = station_buses station
        ret = buses.split(',')
        all_buses[station] = ret
      end
    end

    open(BUSES_JSON, 'w') do |f|
      f.write JSON.dump all_buses
      f.close
    end
  end
  
  task :create_stations_with_coords => :environment do
    STATION_URLS_FILE = File.join Rails.root.to_s, 'db', 'fixtures', 'station_urls.txt'
    
    File.open(STATION_URLS_FILE, 'r') do |f1|
      all_stations = {}
      i = 0
      while line = f1.gets
        open line, "User-Agent" => USER_AGENT do |f|
          dom = Nokogiri::HTML f
          name = dom.css('div[class=Page-Left-Title]').css('h1').text.sub(' Statia ', '')
          coords = dom.css('span[class=Item-Address-Coordinates]')
          station = {}
          station[:name] = name
          station[:lon] = coords.to_s.scan(/\d{1,}[.]\d{1,}/)[0]
          station[:lat] = coords.to_s.scan(/\d{1,}[.]\d{1,}/)[1]
          
          all_stations[i] = station
          
          i += 1
          
          puts "#{i} station"
        end
      end
      f = open(STATIONS_JSON, 'w')
      f.write JSON.dump all_stations
      f.close
    end
  end

  task :add_stations_to_db => :environment do
    Station.destroy_all

    open(STATIONS_JSON, 'r') do |f|
      ret = JSON.load(f.read)
      ret.each do |key, val|
        station = Station.new(
          :name => val["name"],
          :long => val["lon"],
          :lat => val["lat"],
          :type => "bus"
        )
        puts "S-a salvat statia #{val["name"]}: #{station.save}"
      end
    end
  end
end

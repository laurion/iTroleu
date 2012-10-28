require 'nokogiri'
require 'open-uri'
require 'restclient'

STATIONS_URL = "http://www.ratb.ro/statii.php"
ROUTES_URL = "http://www.ratb.ro/v_trasee.php"
USER_AGENT = 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.2 (KHTML, like Gecko) Safari/125.8'
STATIONS_JSON = File.join Rails.root.to_s, 'db', 'fixtures', 'stations.json'
STATIONS_C = File.join Rails.root.to_s, 'db', 'fixtures', 'stations.in'
ROUTES_JSON = File.join Rails.root.to_s, 'db', 'fixtures', 'routes.json'
BUSES_JSON = File.join Rails.root.to_s, 'db', 'fixtures', 'buses.json'

STATION_URLS_FILE = File.join Rails.root.to_s, 'db', 'fixtures', 'station_urls.txt'
ROUTE_URLS_FILE = File.join Rails.root.to_s, 'db', 'fixtures', 'route_urls.txt'

def station_buses(station_name)
  RestClient.post STATIONS_URL, {'tlin6' => station_name} do |f|
    dom = Nokogiri::HTML f
    return dom.css('table')[3].css('tr')[1].css('td')[1].text
  end
end

def route_stations(route_name)
  RestClient.post ROUTES_URL, {'tlin3' => route_name} do |f|
    dom = Nokogiri::HTML f
    return dom.css('table')[5].css('tr').css('td').to_s.scan(/<td>([^<>\d]*)<\/td>\n<td>/imu).to_a
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
  
  task :fetch_transport_routes => :environment do
    all_routes = {}
    open ROUTES_URL, "User-Agent" => USER_AGENT do |f|
      dom = Nokogiri::HTML f
      routes = dom.css('select[name=tlin3]').css('option[value!="0"]').collect{|x| x[:value]}
      routes.each do |route|
        puts "Getting route for #{route}"
        stations = route_stations(route)
        prev = "nothing"
        all_routes[route] = {}
        all_routes[route]["tur"] = [] # tur
        all_routes[route]["retur"] = [] # retur
        what = "tur"
        stations.each do |station|
          if station == prev
            what = "retur"
          end
          all_routes[route][what] << station
          prev = station
        end
      end
    end
    
    open(ROUTES_JSON, 'w') do |f|
      f.write JSON.dump all_routes
      f.close
    end
  end
  
  task :dump_for_c => :environment do
    File.open(STATION_URLS_FILE, 'r') do |f1|
      all_stations = []
      i = 0
      while line = f1.gets
        open line, "User-Agent" => USER_AGENT do |f|
          dom = Nokogiri::HTML f
          name = dom.css('div[class=Page-Left-Title]').css('h1').text.sub(' Statia ', '')
          coords = dom.css('span[class=Item-Address-Coordinates]')
          class Station
            attr_accessor :name, :lon, :lat
          end
          station = Station.new
          puts station.name = name
          puts station.lon = coords.to_s.scan(/\d{1,}[.]\d{1,}/)[0]
          puts station.lat = coords.to_s.scan(/\d{1,}[.]\d{1,}/)[1]
          
          all_stations[i] = station
          
          i += 1
          
          # puts "#{i} station"
        end
      end
      f = open(STATIONS_C, 'w')
      all_stations = all_stations.uniq { |x| x.name }
      f.write "#{all_stations.size}\n"
      all_stations.each do |station|
        f.write "#{station.name}\n#{station.lon}\n#{station.lat}\n"
      end
      f.close
    end
  end
end

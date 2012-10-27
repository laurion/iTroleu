require 'nokogiri'
require 'open-uri'

module ITroleu
  module Scrappers
    class Stations
      STATIONS_URL = "http://www.ratb.ro/statii.php"
      USER_AGENT = 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.2 (KHTML, like Gecko) Safari/125.8'
      
      def download
        open STATIONS_URL, "User-Agent" => USER_AGENT do |f|
          dom = Nokogiri::HTML f
          puts dom.css('select[name=tlin6]').css('option[value!="0"]').collect{|x| x[:value]}
        end
      end
    end
  end
end

scrapper = ITroleu::Scrappers::Stations.new()
scrapper.download

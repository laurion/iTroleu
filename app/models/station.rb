class Station < ActiveRecord::Base
  attr_accessible :lat, :long, :name, :type
end

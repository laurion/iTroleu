require 'csv'

CSV.foreach('test.txt') do |row|
  puts row[0], row[1]
end

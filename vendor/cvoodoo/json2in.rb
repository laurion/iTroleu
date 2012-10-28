require 'json'

routes = JSON.load open('routes.json', 'r').read

open('lines.in', 'w') do |f|
  f.write "#{routes.size}\n"

  routes.each do |name, val|
    f.write "#{name}\n"
    f.write "#{val['tur'].size} #{val['retur'].size}\n"
    val["tur"].each do |name|
      f.write "#{name[0]}\n"
    end
    val["retur"].each do |name|
      f.write "#{name[0]}\n"
    end
  end
end

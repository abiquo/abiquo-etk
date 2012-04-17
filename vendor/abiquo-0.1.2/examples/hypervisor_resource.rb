require 'rubygems'
require 'abiquo'
require 'pp'

auth = Abiquo::BasicAuth.new('Abiquo', 'admin', 'admin')
api = Abiquo::Resource('http://as-testing.bcn.abiquo.com:8080/api', auth)

#
# Iterate over all the racks and print the rack name and the hypervisors underneath
#
api.datacenters.first.racks.each do |rack|
  puts "- RACK [#{rack.name}]" 
  rack.machines.each do |m|
    puts "---" + m.name
  end
end

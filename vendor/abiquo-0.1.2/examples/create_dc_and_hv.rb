require 'rubygems'
require 'abiquo'
require 'pp'

auth = Abiquo::BasicAuth.new('Abiquo', 'admin', 'xabiquo')
api = Abiquo::Resource('http://abiquo-server-ip:8080/api', auth)


#
# Create a DataCenter
#
#puts "Creating DC1 in BCN..."
new_datacenter = api.datacenters.create :name => 'DC1', :location => 'BCN'

#
# Create Remote Services
# 
new_datacenter.remoteServices.create :type => 'VIRTUAL_FACTORY', :uri => 'http://localhost:8080/virtualfactory'
new_datacenter.remoteServices.create :type => 'STORAGE_SYSTEM_MONITOR', :uri => 'http://localhost:8080/ssm'
new_datacenter.remoteServices.create :type => 'VIRTUAL_SYSTEM_MONITOR', :uri => 'http://localhost:8080/vsm'
new_datacenter.remoteServices.create :type => 'NODE_COLLECTOR', :uri => 'http://localhost:8080/nodecollector'
new_datacenter.remoteServices.create :type => 'APPLIANCE_MANAGER', :uri => 'http://localhost:8080/am'
new_datacenter.remoteServices.create :type => 'DHCP_SERVICE', :uri => 'http://localhost:7911'
new_datacenter.remoteServices.create :type => 'BPM_SERVICE', :uri => 'http://localhost:7911'

#
# Create a new Rack
#
puts "Creating rack 'myrack01'..."
new_datacenter.racks.create :name => 'myrack01'

#
# Iterate over all the racks and print the rack name
#
puts "Listing racks.."
new_datacenter.racks.each do |rack|
  pp rack.name
end

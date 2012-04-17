require 'rubygems'
gem 'activesupport', '2.3.8'
require 'abiquo'
require 'pp'

auth = Abiquo::BasicAuth.new('Abiquo', 'admin', 'xabiquo')
api = Abiquo::Resource('http://as-testing:8080/api', auth)

#
# Create a new Rack
#
dc = api.datacenters.first

# Create the rack
rack = dc.racks.create :name => 'myrack01'

#
# This is weird
#
# Create the machine
machine = rack.machines.create :name => 'fooxen', :cpu => '2', :description => 'foo', :hd => '100000', :ram => '1024', :virtualSwitch => 'eth2', :state => 'STOPPED'

# Create the HV
hv = machine.hypervisor.create :type => 'XEN_3', :ip => '10.0.0.1', :port => '8889', :ipService => '10.0.0.1'

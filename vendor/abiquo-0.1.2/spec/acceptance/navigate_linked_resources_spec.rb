require 'spec_helper'

feature "Navigating linked resources" do
  scenario "Link to a collection of resources" do
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").to_return(:body => <<-XML)
      <datacenter>
        <link rel="racks" href="http://abiquo.example.com/api/admin/datacenters/1/racks"/>
      </datacenter>
    XML
    
    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)
    
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1/racks").to_return(:body => <<-XML)
      <racks>
        <rack>
          <name>Rack 1</name>
        </rack>
        <rack>
          <name>Rack 2</name>
        </rack>
      </racks>
    XML
    
    datacenter.racks.size.should == 2
    datacenter.racks.first.name.should == 'Rack 1'
    datacenter.racks.last.name.should == 'Rack 2'
  end
  
  scenario "Link to a collection of resources with params" do
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").to_return(:body => <<-XML)
      <datacenter>
        <link rel="racks" href="http://abiquo.example.com/api/admin/datacenters/1/racks"/>
      </datacenter>
    XML

    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)

    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1/racks").to_return(:body => <<-XML)
      <racks>
        <rack>
          <name>Rack 1</name>
        </rack>
      </racks>
    XML
    
    datacenter.racks.size.should == 1
    datacenter.racks.first.name.should == 'Rack 1'
  end

  scenario "Link to self" do
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").to_return(:body => <<-XML)
      <datacenter>
        <link rel="edit" href="http://abiquo.example.com/datacenters/1"/>
      </datacenter>
    XML
    
    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)
    
    datacenter.url.should == "http://abiquo.example.com/api/admin/datacenters/1"
  end
end

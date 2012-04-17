require "spec_helper"

feature "Fetching individual resources" do  

  scenario "Fetching untyped attributes" do
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").to_return(:body => <<-XML)
      <datacenter>
        <name>Resource Name</name>
        <id>12345</id>
      </datacenter>
    XML

    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)
    datacenter.name.should == "Resource Name"
    datacenter.id.should == "12345"

    expect { datacenter.wadus }.to raise_error(NoMethodError)
  end

  scenario "Fetching typed attributes" do
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").to_return(:body => <<-XML)
      <datacenter>
        <id>12345</id>
        <name>Resource Name</name>
      </datacenter>
    XML

    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)

    datacenter.id.should == "12345"
  end

  scenario "Inspecting a resource" do
    xml = %q{
      <datacenter>
        <id>12345</id>
        <name>Resource Name</name>
      </datacenter>      
    }
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").to_return(:body => xml)

    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)

    Nokogiri.parse(datacenter.inspect).to_xml.should == Nokogiri.parse(xml).to_xml
  end
  
end

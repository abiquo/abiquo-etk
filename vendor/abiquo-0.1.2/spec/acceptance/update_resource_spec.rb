require 'spec_helper'

feature "Updating resources" do
  
  scenario "Updating a resource" do
    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)

    stub_auth_request(:options, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").
      to_return(:headers => {'Allow' => 'GET, PUT, OPTIONS'})

    stub_auth_request(:put, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").with do |req|
      req.body == {:name => "Wadus Wadus"}.to_xml(:root => "datacenter")
    end.to_return(:body => <<-XML)
      <datacenter>
        <name>Wadus Wadus</name>
        <link rel="edit" href="http://abiquo.example.com/api/admin/datacenters/1"/>
      </datacenter>
    XML
    
    
    datacenter.update(:name => "Wadus Wadus")
    
    datacenter.name.should == "Wadus Wadus"
  end
  
end

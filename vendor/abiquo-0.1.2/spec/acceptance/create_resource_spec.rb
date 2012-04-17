require 'spec_helper'

feature "Creating new resources" do
  
  scenario "Creating a resource in a collection" do
    
    datacenters = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters", auth)

    stub_auth_request(:options, "http://admin:admin@abiquo.example.com/api/admin/datacenters").
      to_return(:headers => {'Allow' => 'GET, POST, OPTIONS'})

    stub_auth_request(:post, "http://admin:admin@abiquo.example.com/api/admin/datacenters").with do |req|
      # we parse because comparing strings is too fragile because of order changing, different indentations, etc.
      # we're expecting something very close to this:
      # <datacenter>
      #   <name>Wadus</name>
      # </datacenter>
      Nokogiri.parse(req.body).at_xpath("/datacenter/name").text == "Wadus"
    end.to_return(:body => %q{
      <datacenter>
        <name>Wadus</name>
        <link rel="edit" href="http://abiquo.example.com/api/admin/datacenters/1"/>
      </datacenter>
    })
    
    datacenter = datacenters.create(:name => "Wadus")
    
    datacenter.should be_a(Abiquo::Resource)
    datacenter.name.should == "Wadus"

    stub_auth_request(:options, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").
      to_return(:headers => {'Allow' => 'GET, PUT, OPTIONS'})
    
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").to_return(:body => %q{
      <datacenter>
        <name>Wadus</name>
        <link rel="edit" href="http://abiquo.example.com/api/admin/datacenters/1"/>
      </datacenter>
    })

    datacenter.name == Abiquo::Resource(datacenter.url, auth).name
  end
end

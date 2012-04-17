require 'spec_helper'

feature "Fetching resource collections" do
  
  scenario "Fetch collection" do
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters").to_return(:body => <<-XML)
      <datacenters>
        <datacenter>
          <link rel='edit' href='http://abiquo.example.com/api/admin/datacenters/1'/>
          <name>Resource 1</name>
        </datacenter>
        <datacenter>
          <link rel='edit' href='http://abiquo.example.com/api/admin/datacenters/2'/>
          <name>Resource 2</name>
        </datacenter>
      </datacenters>
    XML
    
    resources = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters", auth)
    
    resources.map(&:name).should == ["Resource 1", "Resource 2"]
    resources.size.should == 2
    resources.first.name.should == "Resource 1"
    resources.last.name.should  == "Resource 2"
  end
  
  scenario "Inspecting a collection" do
    stub_auth_request(:get, "http://admin:admin@abiquo.example.com/api/admin/datacenters").to_return(:body => %q{
      <datacenters><datacenter><name>Resource 1</name></datacenter></datacenters>
    })

    resources = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters", auth)

    resources.inspect.should == "[#{resources.first.inspect}]"
  end

  scenario 'Fetch service document' do
    stub_auth_request(:get, 'http://admin:admin@abiquo.example.com/api').to_return(:body => <<-XML)
      <ns2:service xmlns="http://www.w3.org/2005/Atom" xmlns:ns2="http://www.w3.org/2007/app" xmlns:ns3="http://a9.com/-/spec/opensearch/1.1/" xmlns:ns4="http://www.w3.org/1999/xhtml">
        <ns2:workspace>
          <title>Abiquo administration workspace</title>
          <ns2:collection href="http://localhost:8080/api/admin/datacenters">
            <title>Datacenters</title>
            <ns2:accept/>
          </ns2:collection>
        </ns2:workspace>
      </ns2:service>
    XML

    resources = Abiquo::Resource('http://abiquo.example.com/api', auth)

    lambda { resources.datacenters }.should_not raise_error
  end
  
end

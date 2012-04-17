require 'spec_helper'

feature "Deleting resources" do
  
  scenario "return status 200 when delete is allowed" do
    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)
    
    stub_auth_request(:options, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").
      to_return(:status => 200, :headers => {'Allow' => 'GET, PUT, OPTIONS, HEAD, DELETE'})

    stub_auth_request(:delete, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").to_return(:status => 200)
    
    datacenter.delete
    
    auth_request(:delete, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").should have_been_made.once
  end

  scenario "raise Abiquo::NotAllowed when delete is not allowed" do
    datacenter = Abiquo::Resource("http://abiquo.example.com/api/admin/datacenters/1", auth)

    stub_auth_request(:options, "http://admin:admin@abiquo.example.com/api/admin/datacenters/1").
      to_return(:status => 200, :headers => {'Allow' => 'GET, PUT, OPTIONS, HEAD'})
    
    lambda { datacenter.delete }.should raise_error(Abiquo::NotAllowed)
  end
  
end

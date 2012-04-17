require "spec_helper"

feature "Instantiate resources from xml" do
  
  it "should instantiate the resource without HTTP calls" do
    xml = %q{
      <datacenter>
        <name>Resource 1</name>
      </datacenter>
    }
    datacenter = Abiquo::Resource.from_xml(xml)
    
    datacenter.name.should == "Resource 1"
  end
end

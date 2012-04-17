require 'rubygems'
require 'steak'
require 'webmock/rspec'
require "abiquo"

module Helpers

  def stub_auth_request(*args)
    stub_request(*args)
  end
  
  def auth_request(*args)
    request(*args)
  end
  
  def auth
    Abiquo::BasicAuth.new("Abiquo", "admin", "admin")
  end
end

Spec::Runner.configure do |config|
  config.include Helpers
  config.include WebMock
  config.before(:each) do
    stub_request(:any, //).with { |request| !request.headers.has_key?("Authorization") }.
                           to_return(
                             :status => 401, :headers => {
                               "WWW-Authenticate" => 'Basic realm="Abiquo"'
                            })
  end
  config.after(:each) { reset_webmock }
end

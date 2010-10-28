if ARGV[0] == 'smoketest'

  ARGV.shift

  class MyCLI
    include Mixlib::CLI

    option :user,
      :short => '-u',
      :long => '--user USER',
      :description => 'API username',
      :default => 'admin'

    option :password,
      :short => '-p',
      :long => '--password PASSWORD',
      :description => 'API password',
      :default => 'xabiquo'

    option :host,
      :long => '--host HOST',
      :description => 'API Server Host'

    option :port,
      :long => '--port PORT',
      :description => 'API Server Port',
      :default => 80
    
    option :dc_name,
      :long => '--dc-name DCNAME',
      :description => 'DATA CENTER Name',
      :default => 'SMOKEDC'
    
    option :dc_location,
      :long => '--dc-location DCLOC',
      :description => 'DATA CENTER Location',
      :default => 'Barcelona'

    option :help,
      :short => "-h",
      :long => "--help",
      :description => "Show this message",
      :on => :tail,
      :boolean => true,
      :show_options => true,
      :exit => 0

  end

  cli = MyCLI.new
  cli.parse_options
  auth = Abiquo::BasicAuth.new('Abiquo', cli.config[:user], cli.config[:password])
  api = Abiquo::Resource("http://#{cli.config[:host]}:#{cli.config[:port]}/api", auth)

  #
  # Create a DataCenter
  #
  begin
    puts "Creating #{cli.config[:dc_name]} DC in #{cli.config[:dc_location]}..."
    dc = api.datacenters.create :name => cli.config[:dc_name], :location => cli.config[:dc_location]
  rescue Resourceful::UnsuccessfulHttpRequestError
    $stdout.puts "Error creating datacenter #{cli.config[:dc_name]}. Aborting."
    exit
  end

  #
  # Create Remote Services
  # 
  begin
    puts "Creating Datacenter #{cli.config[:dc_name]} remote services..."
    rs =  dc.remoteServices
    rs.create :type => 'VIRTUAL_FACTORY', :uri => 'http://localhost:80/virtualfactory'
    rs.create :type => 'STORAGE_SYSTEM_MONITOR', :uri => 'http://localhost:80/ssm'
    rs.create :type => 'VIRTUAL_SYSTEM_MONITOR', :uri => 'http://localhost:80/vsm'
    rs.create :type => 'NODE_COLLECTOR', :uri => 'http://localhost:80/nodecollector'
    rs.create :type => 'APPLIANCE_MANAGER', :uri => 'http://localhost:80/am'
    rs.create :type => 'DHCP_SERVICE', :uri => 'http://localhost:7911'
    rs.create :type => 'BPM_SERVICE', :uri => 'http://localhost:7911'
  rescue Resourceful::UnsuccessfulHttpRequestError
    $stdout.puts "Error creating datacenter #{cli.config[:dc_name]} remote services"
  end

  #
  # Create a new Rack
  #
  begin
    puts "Creating rack smokerack01..."
    dc.racks.create :name => 'smokerack01'
  rescue Resourceful::UnsuccessfulHttpRequestError
    $stdout.puts "Error creating datacenter #{cli.config[:dc_name]} rack"
  end

end

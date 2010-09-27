require 'rubygems'
require 'spec'
require 'pp'

__DIR__ = File.dirname(__FILE__)

$LOAD_PATH << File.join(__DIR__, "..", "lib")
require 'resourceful'

$LOAD_PATH << __DIR__ # ./spec

# Spawn the server in another process

@server = Thread.new do

  require 'simple_sinatra_server'
  Sinatra::Default.set(
    :run => true,
    :logging => false
  )

end

# Kill the server process when rspec finishes
at_exit { @server.exit }


# Give the app a change to initialize
$stderr.puts "Waiting for thin to initialize..."
sleep 0.2


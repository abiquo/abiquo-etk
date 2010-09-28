if ARGV[0] == 'version'

  puts "abicli version #{File.read(File.dirname(__FILE__) + '/../../../VERSION').strip.chomp}"

end

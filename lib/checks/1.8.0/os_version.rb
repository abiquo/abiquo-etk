def os_version
  File.read('/etc/redhat-release').strip.chomp rescue 'Unknown'
end

puts "Host OS:".bold.ljust(40) + os_version

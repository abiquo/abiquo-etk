

def fw_rules_defined?
  not `iptables -nL | grep -iv ^chain | grep -iv ^target | grep -v ^$`.empty?
end

puts "Firewall Service:".bold.ljust(40) + (system_service_on?('iptables') ? 'Active'.yellow.bold : 'Disabled'.green.bold)

puts "Firewall Rules:".bold.ljust(40) + (fw_rules_defined? ? 'Found'.yellow.bold : "Not Found".green.bold)


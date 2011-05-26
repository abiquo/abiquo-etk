if abiquo_installed?

def abiquo_tomcat_running?
  return false if not File.exist?(TOMCAT_PID_FILE)

  pid = File.read(TOMCAT_PID_FILE)
  if `ps #{pid}`.lines.count > 1
    return true
  end
  false
end

def tomcat_mem_limits
  return ['unknown','unknown', 'unknown'] if not File.exist?(TOMCAT_PID_FILE)
  pid = File.read(TOMCAT_PID_FILE)
  `ps #{pid}` =~ /-XX:MaxPermSize=(.*?)\s/
  perm_size = $1 || 'unknown'
  `ps #{pid}` =~ /-Xms(.*?)\s/
  xms = $1 || 'unknown'
  `ps #{pid}` =~ /-Xmx(.*?)\s/
  xmx = $1 || 'unknown'
  [perm_size, xms, xmx]
end

puts "Abiquo Service:".bold.ljust(40) + (system_service_on?('abiquo-tomcat') ? 'Active'.green.bold : 'Disabled'.red.bold)

puts "Abiquo Tomcat Status:".bold.ljust(40) + (abiquo_tomcat_running? ? 'Running'.green.bold : "Stopped".red.bold)

if abiquo_tomcat_running?
  p = tomcat_mem_limits
  puts "Tomcat Mem Params:".bold.ljust(40) + "PERM: #{p[0].blue.bold} MIN: #{p[1].blue.bold} MAX: #{p[2].blue.bold}"
end

end

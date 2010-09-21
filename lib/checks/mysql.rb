
if abiquo_installed?

def mysqld_running?
  return true if `service mysqld status`.strip.chomp != 'mysqld is stopped'
end

def mysqld_installed?
  RPMUtils.rpm_installed?('mysql-server')
end

def abiquo_schema_present?
  File.directory? '/var/lib/mysql/kinton'
end

def abiquo_schema_premium?
  File.exist? '/var/lib/mysql/kinton/virtualimage_conversions.frm'
end


puts "MySQL Installed:".bold.ljust(40) + (mysqld_installed? ? 'Yes'.green.bold : 'No')
if mysqld_installed?
  puts "MySQL Running:".bold.ljust(40) + (mysqld_running? ? 'Yes'.green.bold : 'No')
end

if mysqld_installed?
  puts "Abiquo Schema:".bold.ljust(40) + (abiquo_schema_present? ? 'Present'.green.bold : 'Not Found')
  if abiquo_schema_present?
    puts "Abiquo Schema Type:".bold.ljust(40) + (abiquo_schema_premium? ? 'Premium':'Community')
  end
end

end

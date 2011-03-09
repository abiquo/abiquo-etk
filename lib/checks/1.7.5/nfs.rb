
if abiquo_installed?

def nfs_server_running?
  return ((`exportfs`.lines.first.strip.chomp == '/opt/vm_repository') rescue false)
end

if service_installed?('nfs')
  puts "NFS Server Service:".bold.ljust(40) + (system_service_on?('nfs') ? 'Active'.green.bold : 'Disabled'.yellow.bold)

  if system_service_on? 'nfs'
    puts "NFS Server Running:".bold.ljust(40) + (nfs_server_running? ? 'Yes'.bold.green : 'Missing exports'.bold.red)
  end
else
  two_cols('NFS Service:'.bold, 'Not installed')
end

end

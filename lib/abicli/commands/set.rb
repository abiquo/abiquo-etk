
if ARGV[0] == 'set'
  if not File.exist?('/etc/abiquo-release')
    $stderr.puts "Abiquo release version not found. Unsupported installation."
    exit
  end

  rel_info = File.read('/etc/abiquo-release')
  if rel_info =~ /Version: 1\.7/
    load File.dirname(__FILE__) + "/set17.ext"
  elsif rel_info =~ /Version: 1\.6/
    load File.dirname(__FILE__) + "/set168.ext"
  elsif rel_info =~ /Version: 1\.8/
    load File.dirname(__FILE__) + "/set18.ext"
  else
    $stderr.puts "Abiquo release version not found. Unsupported installation."
    exit
  end
end

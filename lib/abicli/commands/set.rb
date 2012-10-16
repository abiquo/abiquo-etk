
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
  elsif rel_info =~ /Version: 2\.0/
    load File.dirname(__FILE__) + "/set20.ext"
  elsif rel_info =~ /Version: 2\.2(.*)/
    load File.dirname(__FILE__) + "/set22.ext"
  elsif rel_info =~ /Version: 2\.3(.*)/
    load File.dirname(__FILE__) + "/set23.ext"
  elsif rel_info =~ /Version: 2\.4(.*)/
    load File.dirname(__FILE__) + "/set24.ext"
  else
    $stderr.puts "Abiquo release version not found. Unsupported installation."
    exit
  end
end

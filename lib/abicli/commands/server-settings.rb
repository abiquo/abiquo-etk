if ARGV[0] == 'server-settings'
  ARGV.shift
  if not File.exist?('/etc/abiquo-release')
    $stderr.puts "Abiquo release version not found. Unsupported installation."
    exit
  end
  rel_info = File.read('/etc/abiquo-release')
  if rel_info =~ /Version: 1\.7/
    load File.dirname(__FILE__) + "/server-settings17.ext"
  elsif rel_info =~ /Version: 1\.6/
    load File.dirname(__FILE__) + "/server-settings168.ext"
  elsif rel_info =~ /Version: 1\.8/
    load File.dirname(__FILE__) + "/server-settings18.ext"
  else
    $stderr.puts "Abiquo release version not found. Unsupported installation."
    exit
  end
end

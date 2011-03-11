
if ARGV[0] == 'set'
  if not File.exist?('/etc/abiquo-release')
    $stderr.puts "Abiquo release version not found. Unsupported installation."
    exit
  end

  begin
    v = AETK::System.abiquo_version
    if v != '1.7.5'
      raise Exception.new
    end
  rescue Exception
    $stderr.puts 'This version of abicli only supports Abiquo 1.7.5. Use abiquo-etk <= 0.4.42'
    exit 1
  end

  rel_info = File.read('/etc/abiquo-release')
  if rel_info =~ /Version: 1\.7/
    load File.dirname(__FILE__) + "/set17.ext"
  elsif rel_info =~ /Version: 1\.6/
    load File.dirname(__FILE__) + "/set168.ext"
  else
    $stderr.puts "Abiquo release version not found. Unsupported installation."
    exit
  end
end

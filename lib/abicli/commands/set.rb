if ARGV[0] == 'set'

  comp = ARGV[1]
  path = ARGV[2]
  val = ARGV[3]
  file = nil
  begin
    if mapping_exist? comp
      val = path
      if mapping_has_proc? comp
        $command_mappings[comp].call(val)
        exit
      end
      comp, path = $command_mappings[comp]
    else
      help
      exit 0
    end
    file = File.join(ABIQUO_BASE_DIR, "config/#{comp}.xml")
    config_set_node(file, path, val, true)
  rescue NoMethodError => e
    $stderr.puts e.message
    $stderr.puts e.backtrace
    $stderr.puts "\nproperty not found in component #{comp.bold}\n\n"
    exit 1
  end

end

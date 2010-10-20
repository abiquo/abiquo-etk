if ARGV[0] == 'remote-services-settings'
  
  ARGV.shift

  if not File.directory? ABIQUO_BASE_DIR
    $stderr.puts "\n'abicli set' command is used to configure the Abiquo Platform.\nUnfortunately, I can't find the Abiquo Platform installed in this server.\n\nTry other commands.\n\n"
    help
    exit 1
  end

  def print_remote_services_settings
    f = ABIQUO_BASE_DIR + '/config/virtualfactory.xml'
    doc = Nokogiri::XML(File.new(f))
    puts
    two_cols("NFS Repository:".bold, config_get_node(doc, 'hypervisors/xenserver/abiquoRepository'))
    two_cols("CIFS Repository:".bold, config_get_node(doc, 'hypervisors/hyperv/destinationRepositoryPath'))
    two_cols("Storage Link URL:".bold, config_get_node(doc, 'storagelink/address'))
    two_cols("Storage Link User:".bold, config_get_node(doc, 'storagelink/user'))
    two_cols("Storage Link Password:".bold, config_get_node(doc, 'storagelink/password'))
    puts
  end

  print_remote_services_settings
end

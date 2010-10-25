# requirements:
# Check kvm installed
# check kvm fullvirt available
# check if qemu-img is installed
# check distribution supported
#
if ARGV[0] == 'instant-deploy'
  ARGV.shift

  #
  # HTTPDownloader code based on code from http://www.vagrantup.com
  #
  require 'net/http'
  require 'net/https'
  require 'open-uri'
  require 'uri'
  require 'fileutils'

  class HTTPDownloader
    def self.match?(uri)
      # URI.parse barfs on '<drive letter>:\\files \on\ windows'
      extracted = URI.extract(uri).first
      extracted && extracted.include?(uri)
    end

    def report_progress(progress, total, show_parts=true)
      line_reset = "\r\e[0K" 
      percent = (progress.to_f / total.to_f) * 100
      line = "Progress: #{percent.to_i}%"
      line << " (#{progress} / #{total})" if show_parts
      line = "#{line_reset}#{line}"
      $stdout.sync = true
      $stdout.print line
    end

    def download!(source_url, destination_file)
      proxy_uri = URI.parse(ENV["http_proxy"] || "")
      uri = URI.parse(source_url)
      http = Net::HTTP.new(uri.host, uri.port, proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)

      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.start do |h|
        h.request_get(uri.request_uri) do |response|
          total = response.content_length
          progress = 0
          segment_count = 0

          response.read_body do |segment|
            # Report the progress out
            progress += segment.length
            segment_count += 1

            # Progress reporting is limited to every 25 segments just so
            # we're not constantly updating
            if segment_count % 25 == 0
              report_progress(progress, total)
              segment_count = 0
            end


            # Store the segment
            destination_file.write(segment)
          end
        end
      end
    rescue SocketError
      raise Errors::DownloaderHTTPSocketError.new
    end
  end
  class InstantDeployCLI
    include Mixlib::CLI

    option :iso_url,
      :long => '--iso-url URL',
      :description => 'Abiquo ISO URL'

    option :mem,
      :long => '--mem MEM',
      :description => 'Virtual Machine memory (in bytes)',
      :default => '512'
    
    option :help,
      :short => "-h",
      :long => "--help",
      :description => ".\n\n",
      :on => :tail,
      :boolean => true,
      :show_options => true,
      :exit => 0
  end

  def preflight_check
    #
    # Check if this is Ubuntu
    #
    if not File.exists? '/etc/lsb-release'
      $stderr.puts "\nYou are not running Ubuntu. Other distributions are not supported.\n\n"
      exit
    end
    if not (File.read('/etc/lsb-release') =~ /DISTRIB_ID=Ubuntu/)
      $stderr.puts "\nYou are not running Ubuntu. Other distributions are not supported\n\n"
      exit
    end

    #
    # Check if KVM installed
    #
    if `which /usr/bin/kvm`.strip.chomp.empty?
      $stderr.puts "\nKVM not found. Install it first:\n\n"
      $stderr.puts "sudo apt-get install kvm\n\n"
      exit
    end
    
    #
    # Check if qemu-img installed
    #
    if `which /usr/bin/qemu-img`.strip.chomp.empty?
      $stderr.puts "\nqemu-img not found. Install it first:\n\n"
      $stderr.puts "sudo apt-get install kvm\n\n"
      exit
    end
  end

  def install_iso(params = {})
    target_dir = params[:target_dir] || "abiquo-instant-deploy-#{Time.now.strftime "%s"}"
    disk_file = params[:disk_file] || "#{target_dir}/abiquo.qcow2"
    iso_url = params[:iso_url]
    mem = params[:mem]
    # Create target directory
    begin
      FileUtils.mkdir(target_dir)
    rescue Exception
      $stderr.puts "\nError creating directory #{target_dir}. Aborting.\n\n"
      exit 1
    end

    # Create qemu img
    if File.exist? disk_file 
      raise Exception.new("Image #{disk_file} already exists")
    end
    `/usr/bin/qemu-img create -f qcow2 #{disk_file} 20GB`
  

    if iso_url =~ /http:\/\//
      # Download the iso
      downloader = HTTPDownloader.new
      puts "Downloading Abiquo ISO..."
      cdrom = ""
      begin
        downloader.download! iso_url, File.new(target_dir + '/instant-deploy.iso', 'w')
        cdrom = target_dir + '/instant-deploy.iso'
      rescue Exception
        $stderr.puts "Error downloading Abiquo ISO. Aborting."
        exit
      end
    else
      if iso_url =~ /file:/
        iso_url.gsub!('file://','')
      end
      if not File.exist? iso_url
        $stderr.puts "The ISO file specified does not exist."
        exit 1
      else
        cdrom = iso_url
      end
    end

    # Boot
    puts "\nAfter the install process, open the browser and type:\n"
    puts "\nhttp://127.0.0.1:8980/client-premium\n\n"
    puts "To open the Abiquo Web Console."
    puts "\nBooting the Installer...\n\n"
    File.open(target_dir + '/run.sh', 'w') do |f|
      f.puts "#!/bin/sh"
      f.puts "MEM=#{mem}"
      f.puts "TAP=vtap0"
      f.puts ""
      f.puts "kvm -m #{mem} -drive file=#{File.basename(disk_file)} -net user,hostfwd=tcp:127.0.0.1:8980-:8080,hostfwd=tcp:127.0.0.1:2300-:22 -net nic -boot order=c > /dev/null 2>&1"
      f.puts ""
      f.puts "#"
      f.puts "# Comment the above line and uncomment this to use bridged networking."
      f.puts "# You will need to have a working bridge setup in order to use this."
      f.puts "# Update TAP variable above to fill your needs."
      f.puts "#"
      f.puts "#kvm -m #{mem} -drive file=#{File.basename(disk_file)} -net tap,ifname=$TAP -net nic -boot order=c > /dev/null 2>&1"
    end
    boot_vm :disk_file => disk_file, :cdrom => cdrom, :mem => mem
  end

  def distribution_version
    /DISTRIB_DESCRIPTION="(.*)"/.match File.read('/etc/lsb-release')
    version = $1.splitp[1] || '0'
    version
  end

  def boot_vm(params = {})
    disk_file = params[:disk_file]
    cdrom = params[:cdrom]
    mem = params[:mem]
    `kvm -m 1024 -drive file=#{disk_file} -net user,hostfwd=tcp:127.0.0.1:8980-:8080,hostfwd=tcp:127.0.0.1:2300-:22 -net nic -drive file=#{cdrom},media=cdrom -boot order=cd -boot once=d > /dev/null 2>&1 `
  end

  target_dir = "abiquo-instant-deploy-#{Time.now.strftime "%s"}"

  trap("INT") { puts "\n\nCleaning Environment..."; exit } 

  preflight_check

  cli = InstantDeployCLI.new
  cli.parse_options
  url = cli.config[:iso_url]
  if url.nil?
    $stderr.puts "\n--iso-url argument is mandatory.\n\n"
    puts cli.opt_parser.help
    exit
  end
  puts "\n"
  print "Abiquo Instant Deploy: ".bold
  puts "One Command Cloud Builder\n\n"
  puts "Building the cloud into #{target_dir.bold} directory..."
  install_iso(:target_dir => target_dir, :iso_url => url, :mem => cli.config[:mem])

end

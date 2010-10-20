if ARGV[0] == 'upload-template'
  ARGV.shift

  # StreamingUploader Adapted by Sergio Rubio <srubio@abiquo.com> for Abiquo
  #
  # inspired by Opscode Chef StreamingCookbookUploader chef/streaming_cookbook_uploader.rb
  # http://opscode.com
  # 
  # inspired by/cargo-culted from http://stanislavvitvitskiy.blogspot.com/2008/12/multipart-post-in-ruby.html
  # On Apr 6, 2010, at 3:00 PM, Stanislav Vitvitskiy wrote:
  #
  # It's free to use / modify / distribute. No need to mention anything. Just copy/paste and use.
  #
  # Regards,
  # Stan

  require 'net/http'

  class StreamingUploader

    class << self

      def post(to_url, params = {}, &block)
        boundary = '----RubyMultipartClient' + rand(1000000).to_s + 'ZZZZZ'
        parts = []
        content_file = nil
        
        unless params.nil? || params.empty?
          params.each do |key, value|
            if value.kind_of?(File)
              content_file = value
              filepath = value.path
              filename = File.basename(filepath)
              parts << StringPart.new( "--" + boundary + "\r\n" +
                                       "Content-Disposition: form-data; name=\"" + key.to_s + "\"; filename=\"" + filename + "\"\r\n" +
                                       "Content-Type: application/octet-stream\r\n\r\n")
              parts << StreamPart.new(value, File.size(filepath))
              parts << StringPart.new("\r\n")
            else
              parts << StringPart.new( "--" + boundary + "\r\n" +
                                       "Content-Disposition: form-data; name=\"" + key.to_s + "\"\r\n\r\n")
              parts << StringPart.new(value.to_s + "\r\n")
            end
          end
          parts << StringPart.new("--" + boundary + "--\r\n")
        end
        
        body_stream = MultipartStream.new(parts, block)
        
        url = URI.parse(to_url)
        
        headers = { 'accept' => 'application/json' }

        req = Net::HTTP::Post.new(url.path)
        req.content_length = body_stream.size
        req.content_type = 'multipart/form-data; boundary=' + boundary unless parts.empty?
        req.body_stream = body_stream
        
        http = Net::HTTP.new(url.host, url.port)
        res = http.request(req)
        #res = http.start {|http_proc| http_proc.request(req) }

        res
      end
      
    end

    class StreamPart
      def initialize(stream, size)
        @stream, @size = stream, size
      end
      
      def size
        @size
      end
      
      # read the specified amount from the stream
      def read(offset, how_much)
        @stream.read(how_much)
      end
    end

    class StringPart
      def initialize(str)
        @str = str
      end
      
      def size
        @str.length
      end

      # read the specified amount from the string startiung at the offset
      def read(offset, how_much)
        @str[offset, how_much]
      end
    end

    class MultipartStream
      def initialize(parts, blk = nil)
        @callback = nil
        if blk
          @callback = blk
        end
        @parts = parts
        @part_no = 0
        @part_offset = 0
      end
      
      def size
        @parts.inject(0) {|size, part| size + part.size}
      end
      
      def read(how_much)
        @callback.call(how_much) if @callback
        return nil if @part_no >= @parts.size

        how_much_current_part = @parts[@part_no].size - @part_offset
        
        how_much_current_part = if how_much_current_part > how_much
                                  how_much
                                else
                                  how_much_current_part
                                end
        
        how_much_next_part = how_much - how_much_current_part

        current_part = @parts[@part_no].read(@part_offset, how_much_current_part)
        
        # recurse into the next part if the current one was not large enough
        if how_much_next_part > 0
          @part_no += 1
          @part_offset = 0
          next_part = read(how_much_next_part)
          current_part + if next_part
                           next_part
                         else
                           ''
                         end
        else
          @part_offset += how_much_current_part
          current_part
        end
      end
    end
    
  end

  class MyCLI
    include Mixlib::CLI

    option :enterprise_id,
      :long => '--enterprise-id USER',
      :description => 'Enterprise ID',
      :default => 1

    option :name,
      :long => '--name NAME',
      :description => 'Template Name'

    option :disk_file,
      :long => '--disk-file FILE',
      :description => 'Virtual disk file to upload'
    
    option :category,
      :long => '--category CAT',
      :description => 'Template Category Name',
      :default => 'Operating Systems'

    option :description,
      :long => '--description DESC',
      :description => 'Template description',
      :default => 'Operating Systems'

    option :icon_url,
      :long => '--icon-url URL',
      :description => 'Template Icon URL',
      :default => 'http://icons.abiquo.com/abiquo.png'

    option :cpus,
      :long => '--cpus NUMBER',
      :description => 'Number of CPUs for the template',
      :default => 1

    option :disk_capacity,
      :long => '--disk-capacity NUMBER',
      :description => 'Virtual Disk Capacity (in bytes). Default 20GB',
      :default => 21474836480

    option :memory,
      :long => '--memory NUMBER',
      :description => 'Template memory (in bytes). Default 512M',
      :default => 524288

    option :rs_url,
      :long => '--rs-url URL',
      :description => 'Remote Services URL (i.e. http://remote-services-ip:8080)'

    option :debug,
      :long => '--debug',
      :description => 'Print debugging output',
      :default => false

    
    option :help,
      :short => "-h",
      :long => "--help",
      :description => "Show this message",
      :on => :tail,
      :boolean => true,
      :show_options => true,
      :exit => 0

  end
  
  cli = MyCLI.new
  cli.parse_options

  # We need this to show the progress percentage 
  file = cli.config[:disk_file]
  if file.nil? or not File.exist?(file)
    $stderr.puts "\n --disk-file is required. Make sure the specified file exists.\n\n"
    exit 1
  end
  rs_url = cli.config[:rs_url]
  if rs_url.nil?
    $stderr.puts "\n --rs-url is required.\n\n"
    exit 1
  end
  tname = cli.config[:name]
  if tname.nil?
    $stderr.puts "\n --name is required.\n\n"
    exit 1
  end

  fo = File.new(file)
  fsize = File.size(file)
  count = 0
json = """{
'idEnterprise':#{cli.config[:enterprise_id]},
'ovfUrl':'http://upload/#{cli.config[:name]}/#{cli.config[:name]}.ovf',
'diskFileFormat':'VMDK_STREAM_OPTIMIZED',
'name':'#{cli.config[:name]}',
'description':'#{cli.config[:description]}',
'categoryName':'#{cli.config[:category]}',
'iconPath':'#{cli.config[:icon_url]}',
'cpu':#{cli.config[:cpus]},
'hd':#{cli.config[:disk_capacity]},
'ram':#{cli.config[:memory]}
}"""
  json.gsub!("'",'"')
  $stdout.sync = true
  line_reset = "\r\e[0K" 
  rsurl = "#{cli.config[:rs_url]}/am/er/#{cli.config[:enterprise_id]}/ovf/upload"
  if cli.config[:debug]
    puts "Upload URL: #{rsurl}"
    puts "JSON sent:\n#{json}"
  end
  StreamingUploader.post(
    rsurl,
    { :ovfpackageinstance => json, :diskFile => fo }
  ) do |size|
    count += size
    per = (100*count)/fsize 
    if per %10 == 0
      print "#{line_reset}Uploading: #{(100*count)/fsize}% " 
    end
  end
  puts "#{line_reset}Progress: #{(100*count)/fsize}% [COMPLETE]"
end

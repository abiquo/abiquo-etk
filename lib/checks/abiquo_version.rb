include AETK::OutputFormatters

def find_version(file)
  File.open(file) do |f|
    m = f.read.match(/return\s+"([\da-zA-Z\.\-)]+?)"\s*;/)
    version = m[1]
    if version and not version.strip.chomp.empty?
      two_cols('Abiquo Version:'.bold, version)
    else
      two_cols 'Abiquo Version:'.bold, 'Unknown'	
    end
  end
end

index_ee = tomcat_base_dir + '/webapps/client-premium/index.html'
index_ce = tomcat_base_dir + '/webapps/client/index.html'

if File.exist? index_ee
  find_version index_ee
elsif File.exist? index_ce
  find_version index_ce
else
  two_cols 'Abiquo Version:'.bold, 'Unknown'	
end

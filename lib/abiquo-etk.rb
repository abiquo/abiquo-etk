Dir[File.dirname(__FILE__) + '/../vendor/*'].each do |dir|
  $: << dir + '/lib'
end

require 'logger'
require 'rubygems'
require 'term/ansicolor'
require 'rpm-utils'
require 'logger'
require 'nokogiri'
require 'mixlib/cli'
require 'abiquo'


#
# CONFIG CONSTANTS
# 

ENV['LANG'] = 'C'
JAVA_BIN = "/usr/java/default/bin/java"
ABIQUO_BASE_DIR='/opt/abiquo'
TOMCAT_DIR='/opt/abiquo/tomcat'
TOMCAT_PID_FILE = '/opt/abiquo/tomcat/work/catalina.pid'
ABIQUO_VERSION = "1.6"
ABIQUO_SERVER_CONFIG = '/opt/abiquo/config/server.xml'
ABIQUO_VIRTUALFACTORY_CONFIG = '/opt/abiquo/config/virtualfactory.xml'
ABIQUO_VSM_CONFIG = '/opt/abiquo/config/vsm.xml'
ABIQUO_NODECOLLECTOR_CONFIG = '/opt/abiquo/config/nodecollector.xml'
ABIQUO_AM_CONFIG = '/opt/abiquo/config/am.xml'
ABIQUO_BPMASYNC_CONFIG = '/opt/abiquo/config/bpm-async.xml'

def abiquo_edition
end

def abiquo_server_settings(file = '/opt/abiquo/config/abiquo.properties')
	settings = {}
  File.read(file).each_line do |l|
    next if l.strip.chomp.empty?
    key,val = l.strip.chomp.split('=')
    settings[key.strip.chomp] = val.strip.chomp rescue ''
  end
  settings
end

def abiquo_rs_settings(file = '/opt/abiquo/config/abiquo.properties')
  abiquo_server_settings
end

def abiquo_base_dir
  return ABIQUO_BASE_DIR
end

def tomcat_base_dir
  return TOMCAT_DIR
end

def abiquo_installed?
  return (File.directory?('/opt/abiquo') && RPMUtils.rpm_installed?('abiquo-core'))
end

def config_property(config, path)
  config.root.xpath(path).text.chomp.strip
end

def abiquo_components_installed
  c = Dir["#{TOMCAT_DIR}/webapps/*"].find_all { |d| File.directory? d }
  c.map { |d| d.split('/').last }

end

def system_service_on?(service)
  not `/sbin/chkconfig --list #{service}|grep 3:on`.empty?
end

def service_installed?(service_name)
  File.exist?("/etc/rc.d/init.d/#{service_name}")
end

def abiquo_server_config
  cfg = nil
  if File.exist? ABIQUO_SERVER_CONFIG
    cfg = Nokogiri::XML(File.new(ABIQUO_SERVER_CONFIG))
  end
  return cfg 
end

def abiquo_virtualfactory_config
  cfg  = nil
  if File.exist? ABIQUO_VIRTUALFACTORY_CONFIG
    cfg= Nokogiri::XML(File.new(ABIQUO_VIRTUALFACTORY_CONFIG))
  end
  return cfg
end


def abiquo_vsm_config
  cfg = nil
  if File.exist? ABIQUO_VSM_CONFIG
    cfg = Nokogiri::XML(File.new(ABIQUO_VSM_CONFIG))
  end
  return cfg
end

def abiquo_nodecollector_config 
  cfg = nil
  if File.exist? ABIQUO_NODECOLLECTOR_CONFIG
    cfg = Nokogiri::XML(File.new(ABIQUO_NODECOLLECTOR_CONFIG))
  end
  return cfg
end

def abiquo_am_config 
  cfg = nil
  if File.exist? ABIQUO_AM_CONFIG
    cfg = Nokogiri::XML(File.new(ABIQUO_AM_CONFIG))
  end
end

def abiquo_bpmasync_config
  cfg = nil
  if File.exist? ABIQUO_BPMASYNC_CONFIG
    cfg = Nokogiri::XML(File.new(ABIQUO_BPMASYNC_CONFIG))
  end
  return cfg
end

module AETK
  
  class Log

    def self.debug(mgs)
      instance.debug msg
    end

    def self.info(msg)
      instance.info msg
    end

    def self.error(msg)
      instance.error msg
    end

    def self.warn(msg)
      instance.warn msg
    end

    def self.instance(file = '/var/log/abiquo-etk.log')
      begin
        @@logger ||= Logger.new file
      rescue Exception
        @@logger ||= Logger.new $stderr
      end
    end

  end


  module OutputFormatters
    
    def two_cols(first, second, justification = 40) 
      puts "#{first}".ljust(justification) + "#{second}"
    end

  end

  def detect_install_type
    AETK::System.detect_install_type
  end

  class System

    def self.abiquo_version
      File.read('/etc/abiquo-release').match(/Version:(.*)/)[1].strip.split(/(-|\s)/)[0].to_s.strip.chomp rescue nil
    end

    def self.detect_install_type
      found = ['bpm-async', 'am', 'server'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      return :monolithic if found
      
      found = ['am', 'virtualfactory', 'bpm-async'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      return :rs_plus_v2v if found
      
      found = ['am', 'virtualfactory'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      return :remote_services if found
      
      found = ['server', 'api'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      return :server if found
      
      found = ['bpm-async'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      return :v2v if found

      return :unknown

    end

    def self.detect_install_type2
      itype = []
      found = ['bpm-async', 'am', 'server'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      itype << :monolithic if found
      
      found = ['am', 'virtualfactory', 'bpm-async'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      itype << :rs_plus_v2v if found
      
      found = ['am', 'virtualfactory'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      itype << :remote_services if found
      
      found = ['server', 'api'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      itype << :server if found
      
      found = ['bpm-async'].each do |dir|
        break if not File.directory?(ABIQUO_BASE_DIR + "/tomcat/webapps/#{dir}")
      end
      itype << :v2v if found

      itype << :cloudnode_vbox if RPMUtils.rpm_installed?('abiquo-virtualbox')
      itype << :cloudnode_kvm if RPMUtils.rpm_installed?('abiquo-cloud-node') and \
        RPMUtils.rpm_installed?('kvm') and not RPMUtils.rpm_installed?('xen')
      itype << :cloudnode_xen if RPMUtils.rpm_installed?('abiquo-cloud-node') and \
        RPMUtils.rpm_installed?('xen')
      
      if itype.size > 0
        itype
      else
        return [:unknown]
      end
    end
  end


  def self.load_plugins(extra_plugins_dir = nil)
    puts "Loading plugins...".yellow.bold
    version = System.abiquo_version
    plugins = Dir[File.dirname(__FILE__) + "/checks/#{version}/*.rb"].sort
    if extra_plugins_dir and File.directory? extra_plugins_dir
      puts "Loading extra plugins...".yellow.bold
      plugins.concat( Dir[extra_plugins_dir + '/*.rb'].sort )
    end
    log = Log.instance
    if log.level == Logger::DEBUG
      plugins.each do |p|
        log.debug "  #{File.basename(p,'.rb')}..."
      end
    end
    plugins.each do |p|
      $stdout.sync = true
      load p
    end

  end

end



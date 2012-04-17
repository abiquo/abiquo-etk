require 'resourceful'
require 'nokogiri'
require File.expand_path('../active_support/inflections', __FILE__)
require File.expand_path('../core_ext', __FILE__)
require File.expand_path('../to_xml', __FILE__)
require 'uri'

module Abiquo

  class NotAllowed < RuntimeError
    def initialize(method, url)
      @method = method
      @url = url
    end

    def message
      "Method #{@method} not allowed for #{@url}"
    end
  end
  
  class BasicAuth < Resourceful::BasicAuthenticator
    def can_handle?(request); true; end
  end
  
  module HttpAccessor
    
    def xml
      @xml ||= begin
        response = http.resource(url_with_params).get
        doc = Nokogiri.parse(response.body)
        # HACK: collections have link and totalSize entities we
        # don't want here
        if not doc.search('/*/totalSize').empty?
          doc.search('/*/totalSize | /*/link').each do |node|
            node.remove
          end
        end
        doc.root
      end
    end
    
    private
    
    def url_with_params
      @options[:expand] = @options[:expand].join(",") if @options[:expand].is_a?(Array)
      params = @options.map { |k, v| "#{k}=#{v}" }.join("&")
      params = "?#{params}" unless params.empty?
      @url + params
    end
    
    def http
      Resourceful::HttpAccessor.new(:authenticator => @auth)
    end

    def rest_options
      @rest_options ||= begin
        response = http.resource(@url).options
        response.header['Allow'].map {|m| m.to_sym }
      end
    end
    
  end
  
  class SingleResource
    
    include HttpAccessor
    
    undef id
    
    def initialize(url, auth, xml = nil, options = {})
      @url = url
      @auth = auth
      @xml = xml
      @options = options
    end
    
    def update(attrs = {})
      raise Abiquo::NotAllowed.new(:PUT, url) unless rest_options.include?(:PUT)
      response = http.resource(url).put(attrs.to_xml(:root => object_type), :content_type => "application/xml")
      @xml = Nokogiri.parse(response.body).root
    end
    
    def delete
      raise Abiquo::NotAllowed.new(:DELETE, url) unless rest_options.include?(:DELETE)
      http.resource(url).delete
    end
    
    def url
      @url ||= xml.at_xpath("./link[@rel='edit']").try(:[], "href")
    end
    
    delegate :to_xml, :to => :xml
    alias_method :inspect, :to_xml
    
    private
    
    def object_type
      @object_type ||= URI.parse(url).path.split("/")[-2].singularize
    end
    
    def method_missing(meth, *args, &blk)
      attribute = xml.at_xpath("./*[name()='#{meth}' or name()='#{attribute_name(meth)}']")
      return node_text(attribute) if attribute
      
      link = xml.at_xpath("./link[@rel='#{meth}' or @rel='#{attribute_name(meth)}']")
      return Resource.new(link["href"], @auth, link.at_xpath("./*"), *args) if link

      if xml.namespaces.has_key?('xmlns:ns2')
        @xml = Nokogiri.parse(xml.to_s.downcase).root
        link = xml.at_xpath("//ns2:collection/xmlns:title[. = '#{meth}']").try(:parent)
        return Resource.new(link['href'], @auth, nil, *args) if link
      end
      
      super
    end
    
    def node_text(node)
      node.text
    end
    
    def attribute_name(attribute)
      attribute.to_s.gsub('_', '-')
    end
    
  end
  
  class ResourceCollection
    
    include HttpAccessor
    
    delegate :inspect, :to => :resources
    
    def initialize(url, auth, xml = nil, options = {})
      @url = url
      @auth = auth
      @xml = xml if options.empty?
      @options = options
    end
    
    def create(attrs = {})
      raise Abiquo::NotAllowed.new(:POST, url) unless rest_options.include?(:POST)
      response = http.resource(url_with_params).post(attrs.to_xml(:root => object_type, :convert_links => true), :content_type => "application/xml")
      doc = Nokogiri.parse(response.body)
      Resource.new(nil, @auth, doc.root)
    end
    
    private
    
    def object_type
      @object_type ||= URI.parse(@url).path.split("/").last.singularize
    end
    
    def resources
      @resources ||= xml.xpath("./*").map { |subnode| Resource.new(subnode.at_xpath("./link[@rel='edit']").try(:[], "href"), @auth, subnode, @options) }
    end
    
    def method_missing(meth, *args, &blk)
      resources.send(meth, *args, &blk)
    end
  end
  
  class Resource
    
    include HttpAccessor
    
    undef id
    undef type
    
    delegate :inspect, :to => :get!
    
    def self.from_xml(xml, auth = nil)
      doc = Nokogiri.parse(xml)
      new(nil, auth, doc.root)
    end
    
    def initialize(url, auth, xml = nil, options = {})
      @url = url
      @auth = auth
      @xml = xml
      @options = options
    end
    
    def method_missing(meth, *args, &blk)
      @resource_object ||= resource_class(meth).new(@url, @auth, @xml, @options)
      @resource_object.send(meth, *args, &blk)
    end
    
    def resource_class(meth)
      @resource_class ||= if (Array.instance_methods + ["create"] - ["delete", "id"]).include?(meth.to_s)
        ResourceCollection
      else
        SingleResource
      end
    end
    
    def get!
      klass = SingleResource
      if (!xml.children.empty? && xml.name.singularize == xml.children.first.name)
        klass = ResourceCollection
      end
      @resource_object = klass.new(@url, @auth, @xml, @options)
    end
        
  end
  
  def self.Resource(url, auth, params = {})
    Resource.new(url, auth, nil, params)
  end
  
end

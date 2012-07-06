require "httparty"
require "ap"

module Buscape
  class API 
    include HTTParty

    def initialize(options = Hash.new(false))
      @base_uri = options[:base_uri]
      @api_id = options[:api_id]
      @sandbox = options[:sandbox]
      options[:base_uri] = base_uri unless options.has_key? :base_uri
      @options = options
      # Raise exception when app_id is invalid/empty
    end

    def base_uri 
      @sandbox ? "http://sandbox.buscape.com" : "http://bws.buscape.com"
    end

    def method_missing(method)
      return Service.new.send(method.to_sym, @options)
    end

    def get(arg)
      if arg.nil?
        
      else
      end
    end

    class << self
      def get(args)
        Buscape::API.new.send(:get, args)
      end
    end
  end
end

# Delegation Class
class Service
  def method_missing(method, options)
    # Select service
    case method
      when :category then @service = "findCategoryList"
      when :categories then @service = "findCategoryList"
    end
    
    # "Initialize" instance variables 
    @options = options
    
    # Build URL
    build_base_uri

    # Get ALL classes from the Builder module
    builder_klasses = Builder.constants

    builder_klasses.each do |klass|
      klass = eval("Builder::#{klass.to_s}").new
      return klass.send(method.to_sym, method, @options) if klass.respond_to? method
    end
  end

  def build_base_uri
    @options[:base_uri] << "/service/#{@service}/#{@options[:app_id]}/"
  end

end

module Builder
  class CategoryBuilder
    include HTTParty

    def category(args, options)
      options[:base_uri] << args.to_s

      @base_uri = options[:base_uri]
      @api_id = options[:api_id]
      @sandbox = options[:sandbox]
      @options = options
      self
    end

    def categories(method, options)
      @options = options
      options[:base_uri] << "?categoryId=0"
      return Buscape::API.send('get', options[:base_uri])
    end

    def method_missing(method, args)
      if Product.new.respond_to?(method)
        Product.new.send(method.to_sym, args, @base_uri)
      end
    end

    def build_uri
    end
  end

  class ProductBuilder
    def product(args, uri)
      @base_uri = uri + "/produto/"+args.to_s
      self
    end

    def method_missing(method)
      @base_uri 
      p "Executar req no servidor com "+ @base_uri
      p "Retornar .name do json recebido"
    end
  end
end

b= Buscape::API.new(:app_id => '67514c517532314f3148343d', :sandbox => true)
#b.category(15).product(19).name
ap b.categories
ap b.categories.with("LG")

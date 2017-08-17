# adapted from https://gist.github.com/evanleck/f60b6437ebbbbf96709937804e81d44c
require 'net/http'
require 'openssl'
require 'uri'
require 'json'

module Pulp
  class ApiClient
    def initialize(domain, port, options = {})
      @http = Net::HTTP.new(domain, port)
      @http.use_ssl      = options.fetch(:use_ssl) { true }
      @http.verify_mode  = options.fetch(:verify_mode) { OpenSSL::SSL::VERIFY_PEER }
      @http.open_timeout = options.fetch(:open_timeout) { 10 }
      @http.read_timeout = options.fetch(:read_timeout) { 120 }
      @http.ca_file      = options.fetch(:ca_file) { nil }
      @http.cert         = options.fetch(:cert) { nil}
      @http.key          = options.fetch(:key) { nil}
    end
  
    def start
      if block_given?
        @http.start unless @http.started?
        yield(self)
        @http.finish if @http.started?
      else
        @http.start unless @http.started?
      end
    end
  
    def finish
      @http.finish if @http.started?
    end
  
    def get(path, params = {})
      uri       = URI.parse(path)
      uri.query = URI.encode_www_form(params) unless params.empty?
      request   = Net::HTTP::Get.new(uri.to_s)
      parse fetch(request)
    end
  
    def post(path, params = {})
      request = Net::HTTP::Post.new(path)
      request.content_type = 'application/json'
      auth = params.delete(:basic_auth)
      request.basic_auth(auth[:username], auth[:password]) if auth
      request.body = JSON.generate(params) unless params.empty?
      parse fetch(request)
    end
  
    def delete(path)
      request = Net::HTTP::Delete.new(path)
      parse fetch(request)
    end
  
    def put(path, params = {})
      request = Net::HTTP::Put.new(path)
      request.content_type = 'application/json'
      request.body = JSON.generate(params) unless params.empty?
      parse fetch(request)
    end
  
    private
  
    def fetch(request)
      request['Accept'] = 'application/json'
      request['Connection'] = 'keep-alive'
      response = @http.request(request)
      response.value || response
    end
  
    def parse(response)
      if response.content_type == 'application/json'
        JSON.parse(response.body)
      else
        response.body
      end
    end
  end
end

require_relative 'api_client.rb'
require 'net/http'
require 'openssl'
require 'date'
require 'uri'
require 'json'

module Pulp
  class Api < Puppet::Provider
    # Modified method from the AWS SDK, rather than including an
    # extra library just to parse an ini file
    def self.ini_parse(file)
      file = File.new(file)
      current_section = {}
      map = {}
      file.rewind
      file.each_line do |line|
        next if line.empty? || line =~ /^\s*#/
        line = line.split(/^|\s;/).first
        section = line.match(/^\s*\[([^\[\]]+)\]\s*$/) unless line.nil?
        if section
          current_section = section[1]
        elsif current_section
          item = line.match(/^\s*(.+?)\s*(:|=)\s*(.+?)\s*$/) unless line.nil?
          if item
            map[current_section] = map[current_section] || {}
            map[current_section][item[1]] = item[3]
          end
        end
      end
      map
    end

    def self.bool_to_sym(value)
      case value
      when true then :true
      when false then :false
      else
        value
      end
    end

    def self.renew_user_certificate?(path)
      if File.file?(path)
        cert       = OpenSSL::X509::Certificate.new(File.read(path))
        expiration = cert.not_after.to_datetime
        expiration < DateTime.now
      else
        true
      end
    end

    def self.get_user_certificate(certificate_path, login_url)
      home       = ENV['HOME'] || '/root'
      config     = ini_parse("#{home}/.pulp/admin.conf")
      uri        = URI.parse(login_url)
      basic_auth = {:username => config['auth']['username'], :password => config['auth']['password']}
      api = Pulp::ApiClient.new(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE)
      response = api.post(uri.request_uri, basic_auth: basic_auth)
      File.open(certificate_path, 'w') { |f| f.puts response.values }
    end

    def self.global_config
      config = ini_parse('/etc/pulp/admin/admin.conf')
      config['server']                         ||= {}
      config['filesystem']                     ||= {}
      config['server']['host']                 ||= Facter['fqdn'].value
      config['server']['port']                 ||= 443
      config['server']['api_prefix']           ||= "/pulp/api"
      config['filesystem']['id_cert_dir']      ||= "~/.pulp"
      config['filesystem']['id_cert_filename'] ||= "user-cert.pem"
      config
    end

    def self.api_location
      config = global_config
      "https://#{config['server']['host']}:#{config['server']['port']}#{config['server']['api_prefix']}"
    end

    def self.cert_path
      config = global_config
      begin
        File.expand_path("#{config['filesystem']['id_cert_dir']}/#{config['filesystem']['id_cert_filename']}")
      rescue
        File.expand_path("#{ENV['USER']}/#{config['filesystem']['id_cert_filename']}")
      end
    end

    def self.check_login
      if renew_user_certificate?(cert_path)
        get_user_certificate(cert_path, "#{api_location}/v2/actions/login/")
      end
    end

    def self.user_auth
      auth = {:cert => nil, :key => nil}
      if File.file?(cert_path)
        auth[:cert] = OpenSSL::X509::Certificate.new(File.read(cert_path))
        auth[:key]  = OpenSSL::PKey::RSA.new(File.read(cert_path))
      end
      auth
    end

    def self.request(method, path, params = {})
      check_login
      uri = URI.parse("#{api_location}/#{path}")
      uri.path.squeeze!('/')
      begin
        api = Pulp::ApiClient.new(uri.host, uri.port, {
          use_ssl: true,
          verify_mode: OpenSSL::SSL::VERIFY_NONE,
          cert: user_auth[:cert],
          key: user_auth[:key]
        })

        Puppet.debug "Sending #{method.upcase} request to #{uri}"
        Puppet.debug "=> Params: #{params.to_json}" unless params.empty?
        api.send(method.to_s.downcase, uri.path, params)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise Puppet::Error, "#{method.upcase} request to #{uri} failed: #{e}"
      end
    end

    def self.get_repo_properties(uri, id)
      properties = {}
      data = request(:get, "#{uri}/#{id}/", details: true)
      data.each do |k, v|
        properties[k.to_sym] = bool_to_sym(v)
      end
      properties
    end

    def self.get_rpm_repos
      params = {:criteria => {:filters => {:notes => {'_repo-type' => 'rpm-repo'}}}}
      request(:post, 'v2/repositories/search/', params)
    end

    def self.get_yum_importer_syncs(repo_id)
      request(:get, "v2/repositories/#{repo_id}/importers/yum_importer/schedules/sync/")
    end

    def request(*args)
      self.class.request(*args)
    end

    def sym_to_bool(value)
      case value
      when 'true', :true then true
      when 'false', :false then false
      else
        value
      end
    end

    def get_repos
      request(:get, 'v2/repositories/')
    end

    def get_repo(repo_id)
      request(:get, "v2/repositories/#{repo_id}/")
    end
  end
end

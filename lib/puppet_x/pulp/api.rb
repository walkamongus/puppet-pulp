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

    def self.sym_to_bool(value)
      case value
      when 'true', :true then true
      when 'false', :false then false
      else
        value
      end
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
      user_config      = ini_parse("#{ENV['HOME']}/.pulp/admin.conf")
      uri              = URI.parse(login_url)
      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request          = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth user_config['auth']['username'], user_config['auth']['password']
      response = http.request(request)
      unless response.code == '200'
        raise Puppet::Error, "Authentication request to #{uri} failed: #{response.code} #{response.message}"
      end
      cert_data = JSON.parse(response.body)
      File.open(certificate_path, 'w') { |f| f.puts cert_data.values }
    end

    def self.request(method, path, payload = nil)
      config = ini_parse('/etc/pulp/admin/admin.conf')
      config['server']                         ||= {}
      config['filesystem']                     ||= {}
      config['server']['host']                 ||= Facter['fqdn'].value
      config['server']['port']                 ||= 443
      config['server']['api_prefix']           ||= "/pulp/api"
      config['filesystem']['id_cert_dir']      ||= "~/.pulp"
      config['filesystem']['id_cert_filename'] ||= "user-cert.pem"

      api_location  = "https://#{config['server']['host']}:#{config['server']['port']}#{config['server']['api_prefix']}"
      verb_map      = {
        :get    => Net::HTTP::Get,
        :post   => Net::HTTP::Post,
        :put    => Net::HTTP::Put,
        :delete => Net::HTTP::Delete
      }

      begin
        cert_path = File.expand_path("#{config['filesystem']['id_cert_dir']}/#{config['filesystem']['id_cert_filename']}")
      rescue
        cert_path = File.expand_path("#{ENV['USER']}/#{config['filesystem']['id_cert_filename']}")
      end

      if renew_user_certificate?(cert_path)
        get_user_certificate(cert_path, "#{api_location}/v2/actions/login/")
      end

      uri = URI.parse("#{api_location}/#{path}")
      uri.path.squeeze!('/')
      cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
      key  = OpenSSL::PKey::RSA.new(File.read(cert_path))

      begin
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE, cert: cert, key: key) do |http|
          request = verb_map[method.to_sym].new(uri.request_uri)
          request.add_field('Content-Type', 'application/json')
          if payload
            redacted_payload = Hash[payload.map { |k, v| [k, k =~ /pass/i ? '<REDACTED>' : v] }]
            request.body     = payload.to_json
          end
          Puppet.debug "Sending #{request.method.upcase} request to #{uri}"
          Puppet.debug "=> Payload: #{redacted_payload.to_json}" if redacted_payload
          http.ca_file = '/etc/pki/tls/certs/ca-bundle.crt'
          http.request(request)
        end

        unless response.code =~ /^2/
          raise Puppet::Error, "#{method.upcase} Request to #{uri} failed: #{response.code} #{response.message}"
        end

        response
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise Puppet::Error, "Request to #{uri} failed: #{e}"
      end
    end

    def self.get_rpm_repos
      payload = {:criteria => {:filters => {:notes => {'_repo-type' => 'rpm-repo'}}}}
      request(:post, 'v2/repositories/search/', payload)
    end

    def self.get_properties(api_root, id)
      properties = {}
      response = request(:get, "#{api_root}/#{id}/?details=True")
      data     = JSON.parse(response.body)
      data.each do |k, v|
        properties[k.to_sym] = bool_to_sym(v)
      end
      properties
    end

    def request(*args)
      self.class.request(*args)
    end

    def get_properties(*args)
      self.class.get_properties(*args)
    end

    def sym_to_bool(*args)
      self.class.sym_to_bool(*args)
    end

    def bool_to_sym(*args)
      self.class.bool_to_sym(*args)
    end

    def get_repos
      request('GET', 'v2/repositories/')
    end

    def get_repo(repo_id)
      request('GET', "v2/repositories/#{repo_id}/")
    end

    def get_rpm_repos
      self.class.get_rpm_repos
    end

    #def get_repo_syncs(repo_id)
    #  # returns an array with 2 values: an array of sync schedules and the repo type
    #  info = request(repo_id, false)
    #  return info if !info

    #  # we need to see the repo type first
    #  case info['notes']['_repo-type']
    #  when 'rpm-repo'
    #    importer = 'yum_importer'
    #  when 'puppet-repo'
    #    importer = 'puppet_importer'
    #  when 'iso-repo'
    #    importer = 'iso_importer'
    #  else
    #    print "[get_repo_syncs] Unknown repo type #{info['notes']['_repo-type']} for repo #{repo_id}.\n"
    #    return [[], nil]
    #  end
    #  [request_api(repo_id, true, "/importers/#{importer}/schedules/sync/"), info['notes']['_repo-type']]
    #end
  end
end

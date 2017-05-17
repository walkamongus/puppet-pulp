require_relative '../../../puppet_x/pulp/api.rb'
require 'pp'

Puppet::Type.type(:pulp_rpm_repo).provide(:api, :parent => Pulp::Api) do
  commands :pulp_admin => '/usr/bin/pulp-admin'

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {
      :auto_publish => false,
      :metadata     => false,
      :distributor  => {},
      :importer     => {}
    }
  end

  def self.instances
    response = get_rpm_repos()
    ids      = JSON.parse(response.body).collect { |item| item['id'] }

    ids.collect do |id|
      repo  = {}
      props = get_properties('/v2/repositories', id)

      repo[:ensure]       = :present
      repo[:name]         = props[:id]
      repo[:display_name] = props[:display_name]
      repo[:description]  = props[:description]
      repo[:notes]        = props[:notes]
      repo[:notes].delete('_repo-type')

      props[:distributors].each do |distributor|
        if distributor['id'] == 'yum_distributor'
          repo[:relative_url]             = distributor['config']['relative_url']
          repo[:http]                     = distributor['config']['http']
          repo[:https]                    = distributor['config']['https']
          repo[:checksum_type]            = distributor['config']['checksum_type']
          repo[:generate_sqlite]          = distributor['config']['generate_sqlite']
          repo[:gpgkey]                   = distributor['config']['gpgkey']
          repo[:repoview]                 = distributor['config']['repoview']
          repo[:updateinfo_checksum_type] = distributor['config']['updateinfo_checksum_type'] || ''
          repo[:auto_publish]             = distributor['auto_publish']
        end
      end

      props[:importers].each do |importer|
        if importer['importer_type_id'] == 'yum_importer'
          repo[:basicauth_username] = importer['config']['basicauth_userername'] || ''
          repo[:basicauth_password] = importer['config']['basicauth_password'] || ''
          repo[:download_policy]    = importer['config']['download_policy']
          repo[:allowed_keys]       = importer['config']['allowed_keys'] || ''
          repo[:require_signature]  = importer['config']['require_signature']
          repo[:feed]               = importer['config']['feed'] || ''
          repo[:validate]           = importer['config']['validate']
          repo[:type_skip_list]     = importer['config']['type_skip_list']
          repo[:ssl_ca_cert]        = importer['config']['ssl_ca_cert']
          repo[:ssl_client_cert]    = importer['config']['ssl_client_cert']
          repo[:ssl_client_key]     = importer['config']['ssl_client_key']
          repo[:ssl_validation]     = importer['config']['ssl_validation']
          repo[:proxy_host]         = importer['config']['proxy_host']
          repo[:proxy_port]         = importer['config']['proxy_port']
          repo[:proxy_username]     = importer['config']['proxy_username']
          repo[:proxy_password]     = importer['config']['proxy_password']
          repo[:max_downloads]      = importer['config']['max_downloads']
          repo[:max_speed]          = importer['config']['max_speed']
          repo[:remove_missing]     = importer['config']['remove_missing']
          repo[:retain_old_count]   = importer['config']['retain_old_count']
        end
      end

      # normalize Boolean and String values to Symbols
      repo.each do |k, v|
        case v when 'true', 'false', true, false then
          repo[k] = v.to_s.to_sym
        end
      end
 
      new(repo)
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    payload = {
      :id                 => @resource[:name],
      :display_name       => @resource[:display_name],
      :description        => @resource[:description],
      :notes              => @resource[:notes].merge({:'_repo-type' => 'rpm-repo'}),
      :importer_type_id   => 'yum_importer',
      :importer_config    => {
        :basicauth_username => @resource[:basicauth_username],
        :basicauth_password => @resource[:basicauth_password],
        :download_policy    => @resource[:download_policy],
        :allowed_keys       => @resource[:allowed_keys],
        :require_signature  => sym_to_bool(@resource['require_signature']),
        :feed               => @resource[:feed],
        :validate           => sym_to_bool(@resource[:validate]),
        :type_skip_list     => @resource[:type_skip_list],
        :ssl_ca_cert        => @resource[:ssl_ca_cert] ? File.read(@resource[:ssl_ca_cert]) : nil,
        :ssl_client_cert    => @resource[:ssl_client_cert] ? File.read(@resource[:ssl_client_cert]) : nil,
        :ssl_client_key     => @resource[:ssl_client_key] ? File.read(@resource[:ssl_client_key]) : nil,
        :ssl_validation     => sym_to_bool(@resource[:ssl_validation]),
        :proxy_host         => @resource[:proxy_host],
        :proxy_port         => @resource[:proxy_port],
        :proxy_username     => @resource[:proxy_username],
        :proxy_password     => @resource[:proxy_password],
        :max_downloads      => @resource[:max_downloads],
        :max_speed          => @resource[:max_speed],
        :remove_missing     => sym_to_bool(@resource[:remove_missing]),
        :retain_old_count   => @resource[:retain_old_count]
      },
      :distributors => [{
        :distributor_id      => 'yum_distributor',
        :distributor_type_id => 'yum_distributor',
        :auto_publish        => sym_to_bool(@resource[:auto_publish]),
        :distributor_config  => {
          :relative_url             => @resource[:relative_url],
          :http                     => sym_to_bool(@resource[:http]),
          :https                    => sym_to_bool(@resource[:https]),
          :checksum_type            => @resource[:checksum_type],
          :generate_sqlite          => sym_to_bool(@resource[:generate_sqlite]),
          :gpgkey                   => @resource[:gpgkey],
          :repoview                 => sym_to_bool(@resource[:repoview]),
          :updateinfo_checksum_type => @resource[:updateinfo_checksum_type]
        }
      }]
    }

    request(:post, '/v2/repositories/', payload)
    request(:post, "/v2/repositories/#{@resource[:name]}/actions/sync/") if @resource[:sync] == :true
    @property_hash[:ensure] = :present
  end

  def destroy
    request(:delete, "/v2/repositories/#{@property_hash[:name]}/")
    @property_hash.clear
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  [
    :relative_url,
    :http,
    :https,
    :checksum_type,
    :generate_sqlite,
    :gpgkey,
    :repoview,
    :updateinfo_checksum_type
  ].each do |property|
    define_method(property.to_s + '=') do |value|
      @property_flush[:distributor][property] = sym_to_bool(value)
    end
  end

  [
    :basicauth_username,
    :basicauth_password,
    :download_policy,
    :allowed_keys,
    :require_signature,
    :feed,
    :validate,
    :type_skip_list,
    :ssl_validation,
    :proxy_host,
    :proxy_port,
    :proxy_username,
    :proxy_password,
    :max_downloads,
    :max_speed,
    :remove_missing,
    :retain_old_count
  ].each do |property|
    define_method(property.to_s + '=') do |value|
      @property_flush[:importer][property] = sym_to_bool(value)
    end
  end

  [
    :ssl_ca_cert,
    :ssl_client_cert,
    :ssl_client_key
  ].each do |property|
    define_method(property.to_s + '=') do |value|
      @property_flush[:importer][property] = File.read(value)
    end
  end

  [
    :name,
    :display_name,
    :description,
    :notes
  ].each do |prop|
    define_method(prop.to_s + '=') do |*|
      @property_flush[:metadata] = true
    end
  end

  def auto_publish=(value)
    @property_flush[:auto_publish] = true
  end

  def update_metadata
    payload = {
      :delta => {
       :display_name => @resource[:display_name],
       :description  => @resource[:description],
       :notes        => @resource[:notes].merge({:'_repo-type' => 'rpm-repo'})
      }
    }
    request(:put, "/v2/repositories/#{@property_hash[:name]}/", payload)
  end

  def update_distributor(key, value)
    payload = { :distributor_config => { key.to_sym => value } }
    request(:put, "/v2/repositories/#{@property_hash[:name]}/distributors/yum_distributor/", payload)
  end

  def update_importer(key, value)
    payload = { :importer_config => { key.to_sym => value } }
    request(:put, "/v2/repositories/#{@property_hash[:name]}/importers/yum_importer/", payload)
  end

  def update_auto_publish
    payload = {:delta => {:auto_publish => sym_to_bool(@resource[:auto_publish])}, :distributor_config => {}}
    request(:put, "/v2/repositories/#{@property_hash[:name]}/distributors/yum_distributor/", payload)
  end

  def flush
    update_metadata if @property_flush[:metadata]
    update_auto_publish if @property_flush[:auto_publish]
    @property_flush[:distributor].each do |key, value|
      update_distributor(key, value)
    end
    @property_flush[:importer].each do |key, value|
      update_importer(key, value)
    end
  end
end

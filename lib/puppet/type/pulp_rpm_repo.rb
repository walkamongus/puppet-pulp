Puppet::Type.newtype(:pulp_rpm_repo) do
  @doc = <<-EOT
    doc
  EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The Pulp repo-id value for uniquely identifying an RPM repo'
  end

  newparam(:admin_conf_file) do
    desc 'The path to the pulp-admin global config file'
    defaultto('/etc/pulp/admin/admin.conf')
  end

  newparam(:sync) do
    desc 'If "true", the repository will be synced immediately after the initial creation.'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:display_name) do
    desc 'The user-friendly display name of the repo'
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:description) do
    desc 'The user-friendly description of the repo'
  end

  newproperty(:notes) do
    desc 'A Hash of notes to associate with the repo'
    defaultto Hash.new
    validate do |value|
      if !value.kind_of?(Hash)
        raise ArgumentError,
        "Notes property should be a hash"
      end
    end
  end

  newproperty(:relative_url) do
    desc 'The relative path the repository will be served from'
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:http) do
    desc 'Whether the repository will be served over HTTP'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:https) do
    desc 'Whether the repository will be served over HTTPS'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:checksum_type) do
    desc 'The type of checksum to use during metadata generation'
  end

  newproperty(:generate_sqlite) do
    desc 'Whether sqlite files will be generated during a repo publish'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:gpgkey) do
    desc 'The GPG key used to sign and verify packages in the repository'
  end

  newproperty(:repoview) do
    desc 'If "true", static HTML files will be generated during publish by the repoview tool for faster browsing of the repository.'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:updateinfo_checksum_type) do
    desc 'The type of checksum to use during updateinfo.xml generation'
  end

  newproperty(:auto_publish) do
    desc 'If "true", a publish operation will be invoked after a successful repository sync.'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:basicauth_username) do
    desc 'The username used to authenticate with sync location via HTTP basic auth.'
  end

  newproperty(:basicauth_password) do
    desc 'The password used to authenticate with sync location via HTTP basic auth.'
  end

  newproperty(:download_policy) do
    desc 'The content downloading policy.'
    newvalues(:immediate, :background, :on_demand)
  end

  newproperty(:allowed_keys) do
    desc 'A list of allowed signature keys that imported packages can be signed with as comma-separated values.'
  end

  newproperty(:require_signature) do
    desc 'Require that imported packages should be signed.'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:feed) do
    desc 'The URL of a source repository to sync'
  end

  newproperty(:validate) do
    desc 'Whether the size and checksum of each synchronized file will be verified against repo metadata'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:type_skip_list, :array_matching => :all) do
    desc 'An Array of types to omit when synchronizing. If none are specified, all types will be synchronized'
    newvalues(:rpm, :drpm, :distribution, :erratum)
  end

  newproperty(:ssl_ca_cert) do
    desc "The full path to the CA certificate used to verify the feed server's SSL certificate"
    def insync?(is)
      is.to_s == File.read(@should.first.to_s)
    end
  end

  newproperty(:ssl_client_cert) do
    desc 'The full path to the certificate to use for authorization when accessing the feed'
    def insync?(is)
      is.to_s == File.read(@should.first.to_s)
    end
  end

  newproperty(:ssl_client_key) do
    desc 'The full path to the private key for the feed_cert certificate'
    def insync?(is)
      is.to_s == File.read(@should.first.to_s)
    end
  end

  newproperty(:ssl_validation) do
    desc "Whether to verify the feed's SSL certificate against the ssl_ca_cert"
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:proxy_host) do
    desc 'The proxy server host to use for syncing repo'
  end

  newproperty(:proxy_port) do
    desc 'The port on the proxy_host to use for syncing repo'
    munge { |value| Integer(value) }
    validate { |value| value =~ /^\d+$/ }
  end

  newproperty(:proxy_username) do
    desc 'The username used to authenticate with the proxy server'
  end

  newproperty(:proxy_password) do
    desc 'The password used to authenticate with the proxy server'
  end

  newproperty(:max_downloads) do
    desc 'The maximum number of downloads that will run concurrently'
    munge { |value| Integer(value) }
    validate do |value|
      value =~ /^\d+$/
    end
  end

  newproperty(:max_speed) do
    desc 'The maximum bandwidth used per download thread specified in bytes (per sec)'
    munge { |value| Integer(value) }
    validate do |value|
      value =~ /^\d+$/
    end
  end

  newproperty(:remove_missing) do
    desc 'Whether units that were previously in the external feed but are no longer found will be removed'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:retain_old_count) do
    desc 'The number of old versions of a unit to keep in a repository'
    munge { |value| Integer(value) }
    validate { |value| value =~ /^\d+$/ }
  end

  autorequire(:file) do
    [
      self[:admin_conf_file],
      self[:ssl_ca_cert],
      self[:ssl_client_cert],
      self[:ssl_client_key]
    ]
  end

  validate do
    if self[:repoview] == :true and self[:generate_sqlite] != :true
      self.fail _("You cannot enable repoview when setting generate_sqlite => false. Repoview functionality depends on sqlite files.")
    end
  end
end

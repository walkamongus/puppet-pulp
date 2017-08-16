# Class: pulp::admin::config
# ===========================
#
# Full description of class pulp::admin::config here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
#
class pulp::admin::config {

  concat { '/etc/pulp/admin/admin.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  concat::fragment { 'admin_server_settings':
    target  => '/etc/pulp/admin/admin.conf',
    order   => '10',
    content => epp('pulp/admin/_server.epp', {
      'host'              => $pulp::admin::host,
      'port'              => $pulp::admin::port,
      'api_prefix'        => $pulp::admin::api_prefix,
      'verify_ssl'        => $pulp::admin::verify_ssl,
      'ca_path'           => $pulp::admin::ca_path,
      'upload_chunk_size' => $pulp::admin::upload_chunk_size,
    }),
  }

  concat::fragment { 'admin_client_settings':
    target  => '/etc/pulp/admin/admin.conf',
    order   => '15',
    content => epp('pulp/admin/_client.epp', {
      'role' => $pulp::admin::role,
    }),
  }

  concat::fragment { 'admin_filesystem_settings':
    target  => '/etc/pulp/admin/admin.conf',
    order   => '20',
    content => epp('pulp/admin/_filesystem.epp', {
      'extensions_dir'     => $pulp::admin::extensions_dir,
      'id_cert_dir'        => $pulp::admin::id_cert_dir,
      'id_cert_filename'   => $pulp::admin::id_cert_filename,
      'upload_working_dir' => $pulp::admin::upload_working_dir,
    }),
  }

  concat::fragment { 'admin_output_settings':
    target  => '/etc/pulp/admin/admin.conf',
    order   => '25',
    content => epp('pulp/admin/_output.epp', {
      'poll_frequency_in_seconds' => $pulp::admin::poll_frequency_in_seconds,
      'enable_color'              => $pulp::admin::enable_color,
      'wrap_to_terminal'          => $pulp::admin::wrap_to_terminal,
      'wrap_width'                => $pulp::admin::wrap_width,
    }),
  }

  if member($pulp::admin::enable_plugins, 'puppet') {
    file { '/etc/pulp/admin/conf.d/puppet.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('pulp/admin/conf.d/puppet.conf.epp', {
        'puppet_upload_working_dir' => $pulp::admin::puppet_upload_working_dir,
        'puppet_upload_chunk_size'  => $pulp::admin::puppet_upload_chunk_size,
      }),
    }
  }
}

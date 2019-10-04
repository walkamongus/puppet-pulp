# == Class pulp::config
#
# This class is called from pulp for service config.
#
class pulp::config {

  concat { '/etc/pulp/server.conf':
    ensure => present,
    owner  => $pulp::http_user,
    group  => $pulp::http_group,
    mode   => '0600',
  }

  concat::fragment { 'database_settings':
    target  => '/etc/pulp/server.conf',
    order   => '10',
    content => epp('pulp/server/_database.epp', {
      'name'             => $pulp::database_name,
      'seeds'            => $pulp::database_seeds,
      'username'         => $pulp::database_username,
      'password'         => $pulp::database_password,
      'replica_set'      => $pulp::database_replica_set,
      'ssl'              => $pulp::database_ssl,
      'ssl_keyfile'      => $pulp::database_ssl_keyfile,
      'ssl_certfile'     => $pulp::database_ssl_certfile,
      'verify_ssl'       => $pulp::database_verify_ssl,
      'ca_path'          => $pulp::database_ca_path,
      'unsafe_autoretry' => $pulp::database_unsafe_autoretry,
      'write_concern'    => $pulp::database_write_concern,
    }),
  }

  concat::fragment { 'server_settings':
    target  => '/etc/pulp/server.conf',
    order   => '15',
    content => epp('pulp/server/_server.epp', {
      'server_name'       => $pulp::server_server_name,
      'key_url'           => $pulp::server_key_url,
      'ks_url'            => $pulp::server_ks_url,
      'default_login'     => $pulp::server_default_login,
      'default_password'  => $pulp::server_default_password,
      'debugging_mode'    => $pulp::server_debugging_mode,
      'log_level'         => $pulp::server_log_level,
      'working_directory' => $pulp::server_working_directory,
    }),
  }

  concat::fragment { 'authentication_settings':
    target  => '/etc/pulp/server.conf',
    order   => '20',
    content => epp('pulp/server/_authentication.epp', {
      'rsa_key' => $pulp::authentication_rsa_key,
      'rsa_pub' => $pulp::authentication_rsa_pub,
    }),
  }

  concat::fragment { 'security_settings':
    target  => '/etc/pulp/server.conf',
    order   => '25',
    content => epp('pulp/server/_security.epp', {
      'cacert'                   => $pulp::security_cacert,
      'cakey'                    => $pulp::security_cakey,
      'ssl_ca_certificate'       => $pulp::security_ssl_ca_certificate,
      'user_cert_expiration'     => $pulp::security_user_cert_expiration,
      'consumer_cert_expiration' => $pulp::security_consumer_cert_expiration,
      'serial_number_path'       => $pulp::security_serial_number_path,
    }),
  }

  concat::fragment { 'consumer_history_settings':
    target  => '/etc/pulp/server.conf',
    order   => '30',
    content => epp('pulp/server/_consumer_history.epp', {
      'lifetime' => $pulp::consumer_history_lifetime,
    }),
  }

  concat::fragment { 'data_reaping_settings':
    target  => '/etc/pulp/server.conf',
    order   => '35',
    content => epp('pulp/server/_data_reaping.epp', {
      'reaper_interval'            => $pulp::data_reaping_reaper_interval,
      'archived_calls'             => $pulp::data_reaping_archived_calls,
      'consumer_history'           => $pulp::data_reaping_consumer_history,
      'repo_sync_history'          => $pulp::data_reaping_repo_sync_history,
      'repo_publish_history'       => $pulp::data_reaping_repo_publish_history,
      'repo_group_publish_history' => $pulp::data_reaping_repo_group_publish_history,
      'task_status_history'        => $pulp::data_reaping_task_status_history,
      'task_result_history'        => $pulp::data_reaping_task_result_history,
    }),
  }

  concat::fragment { 'ldap_settings':
    target  => '/etc/pulp/server.conf',
    order   => '40',
    content => epp('pulp/server/_ldap.epp', {
      'enabled'      => $pulp::ldap_enabled,
      'uri'          => $pulp::ldap_uri,
      'base'         => $pulp::ldap_base,
      'tls'          => $pulp::ldap_tls,
      'default_role' => $pulp::ldap_default_role,
      'filter'       => $pulp::ldap_filter,
    }),
  }

  concat::fragment { 'oauth_settings':
    target  => '/etc/pulp/server.conf',
    order   => '45',
    content => epp('pulp/server/_oauth.epp', {
      'enabled'      => $pulp::oauth_enabled,
      'oauth_key'    => $pulp::oauth_oauth_key,
      'oauth_secret' => $pulp::oauth_oauth_secret,
    }),
  }

  concat::fragment { 'messaging_settings':
    target  => '/etc/pulp/server.conf',
    order   => '50',
    content => epp('pulp/server/_messaging.epp', {
      'url'                         => $pulp::messaging_url,
      'transport'                   => $pulp::messaging_transport,
      'auth_enabled'                => $pulp::messaging_auth_enabled,
      'cacert'                      => $pulp::messaging_cacert,
      'clientcert'                  => $pulp::messaging_clientcert,
      'topic_exchange'              => $pulp::messaging_topic_exchange,
      'event_notifications_enabled' => $pulp::messaging_event_notifications_enabled,
      'event_notification_url'      => $pulp::messaging_event_notification_url,
    }),
  }

  concat::fragment { 'tasks_settings':
    target  => '/etc/pulp/server.conf',
    order   => '55',
    content => epp('pulp/server/_tasks.epp', {
      'broker_url'         => $pulp::tasks_broker_url,
      'celery_require_ssl' => $pulp::tasks_celery_require_ssl,
      'cacert'             => $pulp::tasks_cacert,
      'keyfile'            => $pulp::tasks_keyfile,
      'certfile'           => $pulp::tasks_certfile,
      'login_method'       => $pulp::tasks_login_method,
    }),
  }

  concat::fragment { 'email_settings':
    target  => '/etc/pulp/server.conf',
    order   => '60',
    content => epp('pulp/server/_email.epp', {
      'enabled' => $pulp::email_enabled,
      'host'    => $pulp::email_host,
      'port'    => $pulp::email_port,
      'from'    => $pulp::email_from,
    }),
  }

  concat::fragment { 'lazy_settings':
    target  => '/etc/pulp/server.conf',
    order   => '65',
    content => epp('pulp/server/_lazy.epp', {
      'redirect_host'        => $pulp::lazy_redirect_host,
      'redirect_port'        => $pulp::lazy_redirect_port,
      'redirect_path'        => $pulp::lazy_redirect_path,
      'https_retrieval'      => $pulp::lazy_https_retrieval,
      'download_interval'    => $pulp::lazy_download_interval,
      'download_concurrency' => $pulp::lazy_download_concurrency,
    }),
  }

  concat::fragment { 'profiling_settings':
    target  => '/etc/pulp/server.conf',
    order   => '70',
    content => epp('pulp/server/_profiling.epp', {
      'enabled'   => $pulp::profiling_enabled,
      'directory' => $pulp::profiling_directory,
    }),
  }

  file { $pulp::authentication_rsa_key:
    ensure => file,
    owner  => 'root',
    group  => $pulp::http_group,
    mode   => '0640',
  }

  $pulp::enable_plugins.each |$plugin| {
    case $plugin {
      /rpm/: {
        file { '/etc/pulp/repo_auth.conf':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => epp('pulp/repo_auth.conf.epp', {
            'repo_auth'                   => $pulp::repo_auth,
            'repo_url_prefixes'           => $pulp::repo_auth_repo_url_prefixes,
            'verify_ssl'                  => $pulp::repo_auth_verify_ssl,
            'disabled_authenticators'     => $pulp::repo_auth_disabled_authenticators,
            'cert_location'               => $pulp::repo_auth_cert_location,
            'global_cert_location'        => $pulp::repo_auth_global_cert_location,
            'protected_repo_listing_file' => $pulp::repo_auth_protected_repo_listing_file,
            'crl_location'                => $pulp::repo_auth_crl_location,
          }),
        }

        file { '/etc/pulp/server/plugins.conf.d/yum_importer.json':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => epp('pulp/importer.json.epp', {
            'proxy_host'     => $pulp::proxy_host,
            'proxy_port'     => $pulp::proxy_port,
            'proxy_username' => $pulp::proxy_username,
            'proxy_password' => $pulp::proxy_password,
          }),
        }

        file { '/etc/pulp/server/plugins.conf.d/iso_importer.json':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => epp('pulp/importer.json.epp', {
            'proxy_host'     => $pulp::proxy_host,
            'proxy_port'     => $pulp::proxy_port,
            'proxy_username' => $pulp::proxy_username,
            'proxy_password' => $pulp::proxy_password,
          }),
        }
      }
      /docker/: {
        file { '/etc/pulp/server/plugins.conf.d/docker_importer.json':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => epp('pulp/importer.json.epp', {
            'proxy_host'     => $pulp::proxy_host,
            'proxy_port'     => $pulp::proxy_port,
            'proxy_username' => $pulp::proxy_username,
            'proxy_password' => $pulp::proxy_password,
          }),
        }
      }
      /ostree/: {
        file { '/etc/pulp/server/plugins.conf.d/ostree_importer.json':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => epp('pulp/importer.json.epp', {
            'proxy_host'     => $pulp::proxy_host,
            'proxy_port'     => $pulp::proxy_port,
            'proxy_username' => $pulp::proxy_username,
            'proxy_password' => $pulp::proxy_password,
          }),
        }
      }
      /puppet/: {
        file { '/etc/pulp/server/plugins.conf.d/puppet_importer.json':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => epp('pulp/importer.json.epp', {
            'proxy_host'     => $pulp::proxy_host,
            'proxy_port'     => $pulp::proxy_port,
            'proxy_username' => $pulp::proxy_username,
            'proxy_password' => $pulp::proxy_password,
          }),
        }
      }
      default: {
        fail("Enabled plugin: ${plugin} not currently supported in pulp::config")
      }
    }
  }


  file { '/etc/sysconfig/pulp_workers':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('pulp/sysconfig_pulp_workers.epp', {
      'number_workers'      => $pulp::number_workers,
      'max_tasks_per_child' => $pulp::max_tasks_per_child,
    }),
  }

  exec { 'run_pulp-gen-key-pair':
    command => '/bin/pulp-gen-key-pair',
    onlyif  =>  '/usr/bin/test -f /bin/pulp-gen-key-pair',
    creates => '/etc/pki/pulp/rsa_pub.key',
  }

  exec { 'run_pulp-gen-ca-certificate':
    command => '/bin/pulp-gen-ca-certificate',
    onlyif  =>  '/usr/bin/test -f /bin/pulp-gen-ca-certificate',
    creates => '/etc/pki/pulp/ca.crt',
  }

  file { '/etc/httpd/conf.d/pulp.conf':
    ensure => absent,
  }
  file { '/etc/httpd/conf.d/pulp_content.conf':
    ensure => absent,
  }
}

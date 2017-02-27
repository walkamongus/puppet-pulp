# documentation goes here
class pulp::params {

  $version              = '2.12'
  $pulp_packages_ensure = 'present'
  $gofer_package_ensure = 'present'
  $enable_plugins       = ['rpm', ]
  $http_user            = 'apache'
  $manage_http_user     = true
  $http_group           = 'apache'
  $manage_http_group    = true
  $proxy_host           = undef
  $proxy_port           = undef
  $proxy_username       = undef
  $proxy_password       = undef
  $number_workers       = undef
  $max_tasks_per_child  = undef
  $manage_repo          = true
  $repo_proxy           = undef

  $repo_auth                             = false
  $repo_auth_repo_url_prefixes           = ['/pulp/repos', '/pulp/ostree/web', '/pulp/isos']
  $repo_auth_verify_ssl                  = false
  $repo_auth_disabled_authenticators     = []
  $repo_auth_cert_location               = '/etc/pki/pulp/content'
  $repo_auth_global_cert_location        = '/etc/pki/pulp/content'
  $repo_auth_protected_repo_listing_file = '/etc/pki/pulp/content/pulp-protected-repos'
  $repo_auth_crl_location                = '/etc/pki/pulp/content'

  # [database]
  $database_name             = 'pulp_database'
  $database_seeds            = 'localhost:27017'
  $database_username         = undef
  $database_password         = undef
  $database_replica_set      = undef
  $database_ssl              = false
  $database_ssl_keyfile      = undef
  $database_ssl_certfile     = undef
  $database_verify_ssl       = true
  $database_ca_path          = undef
  $database_unsafe_autoretry = false
  $database_write_concern    = 'majority'

  #[server]
  $server_server_name       = $::fqdn
  $server_key_url           = '/pulp/gpg'
  $server_ks_url            = '/pulp/ks'
  $server_default_login     = 'admin'
  $server_default_password  = 'admin'
  $server_debugging_mode    = false
  $server_log_level         = 'INFO'
  $server_working_directory = '/var/cache/pulp'

  #[authentication]
  $authentication_rsa_key = '/etc/pki/pulp/rsa.key'
  $authentication_rsa_pub = '/etc/pki/pulp/rsa_pub.key'

  #[security]
  $security_cacert                   = undef
  $security_cakey                    = undef
  $security_ssl_ca_certificate       = undef
  $security_user_cert_expiration     = 7
  $security_consumer_cert_expiration = 3650
  $security_serial_number_path       = '/var/lib/pulp/sn.dat'

  #[consumer_history]
  $consumer_history_lifetime = 180

  #[data_reaping]
  $data_reaping_reaper_interval            = 0.25
  $data_reaping_archived_calls             = 0.5
  $data_reaping_consumer_history           = 60
  $data_reaping_repo_sync_history          = 60
  $data_reaping_repo_publish_history       = 60
  $data_reaping_repo_group_publish_history = 60
  $data_reaping_task_status_history        = 7
  $data_reaping_task_result_history        = 3

  #[ldap]
  $ldap_enabled      = false
  $ldap_uri          = 'ldap://localhost'
  $ldap_base         = 'dc=localhost'
  $ldap_tls          = 'no'
  $ldap_default_role = '<role-id>'
  $ldap_filter       = '(gidNumber=200)'

  #[oauth]
  $oauth_enabled      = false
  $oauth_oauth_key    = 'pulp'
  $oauth_oauth_secret = 'secret'

  #[messaging]
  $messaging_url                         = 'tcp://localhost:5672'
  $messaging_transport                   = 'qpid'
  $messaging_auth_enabled                = true
  $messaging_cacert                      = undef
  $messaging_clientcert                  = undef
  $messaging_topic_exchange              = 'amq.topic'
  $messaging_event_notifications_enabled = false
  $messaging_event_notification_url      = 'qpid://localhost:5672/'

  #[tasks]
  $tasks_broker_url         = 'qpid://localhost:5672'
  $tasks_celery_require_ssl = false
  $tasks_cacert             = undef
  $tasks_keyfile            = undef
  $tasks_certfile           = undef
  $tasks_login_method       = undef

  #[email]
  $email_enabled = false
  $email_host    = 'localhost'
  $email_port    = 25
  $email_from    = 'no-reply@your.domain'

  #[lazy]
  $lazy_redirect_host        = $::fqdn
  $lazy_redirect_port        = 80
  $lazy_redirect_path        = '/streamer/'
  $lazy_https_retrieval      = false
  $lazy_download_interval    = 10
  $lazy_download_concurrency = 5

  #[profiling]
  $profiling_enabled   = false
  $profiling_directory = '/var/lib/pulp/c_profiles'

}

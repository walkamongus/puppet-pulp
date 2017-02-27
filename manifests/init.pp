# Class: pulp
# ===========================
#
# Full description of class pulp here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class pulp (
  String $version                              = $pulp::params::version,
  String $pulp_packages_ensure                 = $pulp::params::pulp_packages_ensure,
  String $gofer_package_ensure                 = $pulp::params::gofer_package_ensure,
  Array[String] $enable_plugin                 = $pulp::params::enable_plugins,
  String $http_user                            = $pulp::params::http_user,
  Boolean $manage_http_user                    = $pulp::params::manage_http_user,
  String $http_group                           = $pulp::params::http_group,
  Boolean $manage_http_group                   = $pulp::params::manage_http_group,
  Boolean $manage_repo                         = $pulp::params::manage_repo,
  Variant[String, Undef] $repo_proxy           = $pulp::params::repo_proxy,
  Variant[String, Undef] $proxy_host           = $pulp::params::proxy_host,
  Variant[Integer, Undef] $proxy_port          = $pulp::params::proxy_port,
  Variant[String, Undef] $proxy_username       = $pulp::params::proxy_username,
  Variant[String, Undef] $proxy_password       = $pulp::params::proxy_password,
  Variant[Integer, Undef] $number_workers      = $pulp::params::number_workers,
  Variant[Integer, Undef] $max_tasks_per_child = $pulp::params::max_tasks_per_child,

  Boolean $repo_auth                                           = $pulp::params::repo_auth,
  Array[String] $repo_auth_repo_url_prefixes                  = $pulp::params::repo_auth_repo_url_prefixes,
  Boolean $repo_auth_verify_ssl                               = $pulp::params::repo_auth_verify_ssl,
  Array[String] $repo_auth_disabled_authenticators            = $pulp::params::repo_auth_disabled_authenticators,
  Stdlib::Absolutepath $repo_auth_cert_location               = $pulp::params::repo_auth_cert_location,
  Stdlib::Absolutepath $repo_auth_global_cert_location        = $pulp::params::repo_auth_global_cert_location,
  Stdlib::Absolutepath $repo_auth_protected_repo_listing_file = $pulp::params::repo_auth_protected_repo_listing_file,
  Stdlib::Absolutepath $repo_auth_crl_location                = $pulp::params::repo_auth_crl_location,

  String $database_name                                  = $pulp::params::database_name,
  String $database_seeds                                 = $pulp::params::database_seeds,
  Variant[String, Undef] $database_username              = $pulp::params::database_username,
  Variant[String, Undef] $database_password              = $pulp::params::database_password,
  Variant[String, Undef] $database_replica_set           = $pulp::params::database_replica_set,
  Boolean $database_ssl                                  = $pulp::params::database_ssl,
  Variant[String, Undef] $database_ssl_keyfile           = $pulp::params::database_ssl_keyfile,
  Variant[String, Undef] $database_ssl_certfile          = $pulp::params::database_ssl_certfile,
  Boolean $database_verify_ssl                           = $pulp::params::database_verify_ssl,
  Variant[Stdlib::Absolutepath, Undef] $database_ca_path = $pulp::params::database_ca_path,
  Boolean $database_unsafe_autoretry                     = $pulp::params::database_unsafe_autoretry,
  Enum['majority', 'all'] $database_write_concern        = $pulp::params::database_write_concern,

  String $server_server_name                     = $pulp::params::server_server_name,
  String $server_key_url                         = $pulp::params::server_key_url,
  String $server_ks_url                          = $pulp::params::server_ks_url,
  String $server_default_login                   = $pulp::params::server_default_login,
  String $server_default_password                = $pulp::params::server_default_password,
  Boolean $server_debugging_mode                 = $pulp::params::server_debugging_mode,
  String $server_log_level                       = $pulp::params::server_log_level,
  Stdlib::Absolutepath $server_working_directory = $pulp::params::server_working_directory,

  Stdlib::Absolutepath $authentication_rsa_key = $pulp::params::authentication_rsa_key,
  Stdlib::Absolutepath $authentication_rsa_pub = $pulp::params::authentication_rsa_pub,

  Variant[Stdlib::Absolutepath, Undef] $security_cacert             = $pulp::params::security_cacert,
  Variant[Stdlib::Absolutepath, Undef] $security_cakey              = $pulp::params::security_cakey,
  Variant[Stdlib::Absolutepath, Undef] $security_ssl_ca_certificate = $pulp::params::security_ssl_ca_certificate,
  Integer $security_user_cert_expiration                            = $pulp::params::security_user_cert_expiration,
  Integer $security_consumer_cert_expiration                        = $pulp::params::security_consumer_cert_expiration,
  Stdlib::Absolutepath $security_serial_number_path                 = $pulp::params::security_serial_number_path,

  Integer $consumer_history_lifetime = $pulp::params::consumer_history_lifetime,

  Numeric $data_reaping_reaper_interval            = $pulp::params::data_reaping_reaper_interval,
  Numeric $data_reaping_archived_calls             = $pulp::params::data_reaping_archived_calls,
  Integer $data_reaping_consumer_history           = $pulp::params::data_reaping_consumer_history,
  Integer $data_reaping_repo_sync_history          = $pulp::params::data_reaping_repo_sync_history,
  Integer $data_reaping_repo_publish_history       = $pulp::params::data_reaping_repo_publish_history,
  Integer $data_reaping_repo_group_publish_history = $pulp::params::data_reaping_repo_group_publish_history,
  Integer $data_reaping_task_status_history        = $pulp::params::data_reaping_task_status_history,
  Integer $data_reaping_task_result_history        = $pulp::params::data_reaping_task_result_history,

  Boolean $ldap_enabled     = $pulp::params::ldap_enabled,
  String $ldap_uri          = $pulp::params::ldap_uri,
  String $ldap_base         = $pulp::params::ldap_base,
  String $ldap_tls          = $pulp::params::ldap_tls,
  String $ldap_default_role = $pulp::params::ldap_default_role,
  String $ldap_filter       = $pulp::params::ldap_filter,

  Boolean $oauth_enabled     = $pulp::params::oauth_enabled,
  String $oauth_oauth_key    = $pulp::params::oauth_oauth_key,
  String $oauth_oauth_secret = $pulp::params::oauth_oauth_secret,

  String $messaging_url                                      = $pulp::params::messaging_url,
  String $messaging_transport                                = $pulp::params::messaging_transport,
  Boolean $messaging_auth_enabled                            = $pulp::params::messaging_auth_enabled,
  Variant[Stdlib::Absolutepath, Undef] $messaging_cacert     = $pulp::params::messaging_cacert,
  Variant[Stdlib::Absolutepath, Undef] $messaging_clientcert = $pulp::params::messaging_clientcert,
  String $messaging_topic_exchange                           = $pulp::params::messaging_topic_exchange,
  Boolean $messaging_event_notifications_enabled             = $pulp::params::messaging_event_notifications_enabled,
  String $messaging_event_notification_url                   = $pulp::params::messaging_event_notification_url,

  String $tasks_broker_url                             = $pulp::params::tasks_broker_url,
  Boolean $tasks_celery_require_ssl                    = $pulp::params::tasks_celery_require_ssl,
  Variant[Stdlib::Absolutepath, Undef] $tasks_cacert   = $pulp::params::tasks_cacert,
  Variant[Stdlib::Absolutepath, Undef] $tasks_keyfile  = $pulp::params::tasks_keyfile,
  Variant[Stdlib::Absolutepath, Undef] $tasks_certfile = $pulp::params::tasks_certfile,
  Variant[String, Undef] $tasks_login_method           = $pulp::params::tasks_login_method,

  Boolean $email_enabled = $pulp::params::email_enabled,
  String $email_host     = $pulp::params::email_host,
  Integer $email_port    = $pulp::params::email_port,
  String $email_from     = $pulp::params::email_from,

  String $lazy_redirect_host         = $pulp::params::lazy_redirect_host,
  Integer $lazy_redirect_port        = $pulp::params::lazy_redirect_port,
  String $lazy_redirect_path         = $pulp::params::lazy_redirect_path,
  Boolean $lazy_https_retrieval      = $pulp::params::lazy_https_retrieval,
  Integer $lazy_download_interval    = $pulp::params::lazy_download_interval,
  Integer $lazy_download_concurrency = $pulp::params::lazy_download_concurrency,

  Boolean $profiling_enabled                = $pulp::params::profiling_enabled,
  Stdlib::Absolutepath $profiling_directory = $pulp::params::profiling_directory
) inherits ::pulp::params {

  class { '::pulp::repos': } ->
  class { '::pulp::install': } ->
  class { '::pulp::config': } ~>
  class { '::pulp::service': } ->
  Class['::pulp']

}

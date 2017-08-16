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
  String $version,
  String $pulp_packages_ensure,
  String $gofer_package_ensure,
  Array[String] $enable_plugin,
  String $http_user,
  Boolean $manage_http_user,
  String $http_group,
  Boolean $manage_http_group,
  Boolean $manage_repo,
  Variant[String, Undef] $repo_proxy,
  Variant[String, Undef] $proxy_host,
  Variant[Integer, Undef] $proxy_port,
  Variant[String, Undef] $proxy_username,
  Variant[String, Undef] $proxy_password,
  Variant[Integer, Undef] $number_workers,
  Variant[Integer, Undef] $max_tasks_per_child,

  Boolean $repo_auth,
  Array[String] $repo_auth_repo_url_prefixes,
  Boolean $repo_auth_verify_ssl,
  Array[String] $repo_auth_disabled_authenticators,
  Stdlib::Absolutepath $repo_auth_cert_location,
  Stdlib::Absolutepath $repo_auth_global_cert_location,
  Stdlib::Absolutepath $repo_auth_protected_repo_listing_file,
  Stdlib::Absolutepath $repo_auth_crl_location,

  String $database_name,
  String $database_seeds,
  Variant[String, Undef] $database_username,
  Variant[String, Undef] $database_password,
  Variant[String, Undef] $database_replica_set,
  Boolean $database_ssl,
  Variant[String, Undef] $database_ssl_keyfile,
  Variant[String, Undef] $database_ssl_certfile,
  Boolean $database_verify_ssl,
  Variant[Stdlib::Absolutepath, Undef] $database_ca_path,
  Boolean $database_unsafe_autoretry,
  Enum['majority', 'all'] $database_write_concern,

  String $server_server_name,
  String $server_key_url,
  String $server_ks_url,
  String $server_default_login,
  String $server_default_password,
  Boolean $server_debugging_mode,
  String $server_log_level,
  Stdlib::Absolutepath $server_working_directory,

  Stdlib::Absolutepath $authentication_rsa_key,
  Stdlib::Absolutepath $authentication_rsa_pub,

  Variant[Stdlib::Absolutepath, Undef] $security_cacert,
  Variant[Stdlib::Absolutepath, Undef] $security_cakey,
  Variant[Stdlib::Absolutepath, Undef] $security_ssl_ca_certificate,
  Integer $security_user_cert_expiration,
  Integer $security_consumer_cert_expiration,
  Stdlib::Absolutepath $security_serial_number_path,

  Integer $consumer_history_lifetime,

  Numeric $data_reaping_reaper_interval,
  Numeric $data_reaping_archived_calls,
  Integer $data_reaping_consumer_history,
  Integer $data_reaping_repo_sync_history,
  Integer $data_reaping_repo_publish_history,
  Integer $data_reaping_repo_group_publish_history,
  Integer $data_reaping_task_status_history,
  Integer $data_reaping_task_result_history,

  Boolean $ldap_enabled,
  String $ldap_uri,
  String $ldap_base,
  String $ldap_tls,
  String $ldap_default_role,
  String $ldap_filter,

  Boolean $oauth_enabled,
  String $oauth_oauth_key,
  String $oauth_oauth_secret,

  String $messaging_url,
  String $messaging_transport,
  Boolean $messaging_auth_enabled,
  Variant[Stdlib::Absolutepath, Undef] $messaging_cacert,
  Variant[Stdlib::Absolutepath, Undef] $messaging_clientcert,
  String $messaging_topic_exchange,
  Boolean $messaging_event_notifications_enabled,
  String $messaging_event_notification_url,

  String $tasks_broker_url,
  Boolean $tasks_celery_require_ssl,
  Variant[Stdlib::Absolutepath, Undef] $tasks_cacert,
  Variant[Stdlib::Absolutepath, Undef] $tasks_keyfile,
  Variant[Stdlib::Absolutepath, Undef] $tasks_certfile,
  Variant[String, Undef] $tasks_login_method,

  Boolean $email_enabled,
  String $email_host,
  Integer $email_port,
  String $email_from,

  String $lazy_redirect_host,
  Integer $lazy_redirect_port,
  String $lazy_redirect_path,
  Boolean $lazy_https_retrieval,
  Integer $lazy_download_interval,
  Integer $lazy_download_concurrency,

  Boolean $profiling_enabled,
  Stdlib::Absolutepath $profiling_directory,
) {

  contain ::pulp::repos
  contain ::pulp::install
  contain ::pulp::config
  contain ::pulp::service

  Class['::pulp::repos']
  -> Class['::pulp::install']
  -> Class['::pulp::config']
  ~> Class['::pulp::service']

}

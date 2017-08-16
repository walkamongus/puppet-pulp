# Class: pulp::admin
# ===========================
#
# Full description of class pulp::admin here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
#
class pulp::admin (
  String $packages_ensure,
  Array[Pulp::Plugin] $enable_plugins,
  String $host,
  Integer[1, 65535] $port,
  String $api_prefix,
  Boolean $verify_ssl,
  Stdlib::Absolutepath $ca_path,
  Integer[0] $upload_chunk_size,
  String $role,
  Stdlib::Absolutepath $extensions_dir,
  String $id_cert_dir,
  String $id_cert_filename,
  String $upload_working_dir,
  Integer[0] $poll_frequency_in_seconds,
  Boolean $enable_color,
  Boolean $wrap_to_terminal,
  Integer[0] $wrap_width,
  String $puppet_upload_working_dir,
  Integer[0] $puppet_upload_chunk_size,
) {

  contain ::pulp::admin::install
  contain ::pulp::admin::config

  Class['pulp::admin::install']
  -> Class['pulp::admin::config']

}

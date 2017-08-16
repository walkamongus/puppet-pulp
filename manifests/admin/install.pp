# Class: pulp::admin::install
# ===========================
#
# Full description of class pulp::admin::install here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
#
class pulp::admin::install {

  package { 'pulp-admin-client':
    ensure => $pulp::admin::packages_ensure,
  }

  $pulp::admin::enable_plugins.each |$plugin| {
    package { "pulp-${plugin}-admin-extensions":
      ensure => $pulp::admin::packages_ensure,
    }
    if $plugin =~ /(?i:puppet)/ {
      package { ['pulp-puppet-tools', 'python-pulp-puppet-common']:
        ensure => $pulp::admin::packages_ensure,
      }
    }
  }

}

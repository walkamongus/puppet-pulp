# == Class pulp::install
#
# This class is called from pulp for install.
#
class pulp::install {

  package { ['pulp-server', 'pulp-selinux', 'python-pulp-streamer']:
    ensure => $::pulp::pulp_packages_ensure,
  }

  case $pulp::messaging_transport {
    /qpid/: {
      package { 'python-gofer-qpid':
        ensure => $pulp::gofer_package_ensure,
      }
    }
    /rabbitmq/: {
      package { 'python-gofer-amqp':
        ensure => $pulp::gofer_package_ensure,
      }
    }
    default: {
      fail("messaging transport: ${pulp::messaging_transport} not supported. Options are 'qpid' or 'rabbitmq'.")
    }
  }

  $pulp::enable_plugins.each |$plugin| {
    package { "pulp-${plugin}-plugins":
      ensure => $pulp::pulp_packages_ensure,
    }
  }

  if $pulp::manage_http_user {
    user { $pulp::http_user:
      ensure => present,
    }
  }

  if $pulp::manage_http_group {
    group { $pulp::http_group:
      ensure => present,
    }
  }

}

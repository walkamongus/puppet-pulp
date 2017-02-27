# == Class pulp::service
#
# This class is meant to be called from pulp.
# It ensure the service is running.
#
class pulp::service {

  exec { 'reload_systemctl_daemon':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    before      => [
      Service['pulp_celerybeat'],
      Service['pulp_resource_manager'],
      Service['pulp_workers'],
      Service['pulp_streamer'],
    ],
  }

  service { 'pulp_celerybeat':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

  service { 'pulp_resource_manager':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

  service { 'pulp_workers':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

  service { 'pulp_streamer':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

}

# == Class pulp::service
#
# This class is meant to be called from pulp.
# It ensure the service is running.
#
class pulp::service {

  if $pulp::exec_pulp_manage_db {
    exec { 'pulp-manage-db-stop-services':
      command => 'systemctl stop pulp_*.service',
      path    => [
        '/usr/bin',
        '/usr/local/sbin',
        '/usr/sbin',
      ],
      before  =>  Exec['pulp-manage-db'],
      unless  => "grep -q ${pulp::version} /var/lib/pulp/pulp-manage-db.init"
    }

    exec { 'pulp-manage-db':
      command   => "pulp-manage-db && echo ${pulp::version} > /var/lib/pulp/pulp-manage-db.init",
      user      => $pulp::http_user,
      path      => [
        'usr/local/bin',
        '/usr/bin',
        '/usr/local/sbin',
        '/usr/sbin',
      ],
      timeout   => 240,
      logoutput => true,
      unless    => "grep -q ${pulp::version} /var/lib/pulp/pulp-manage-db.init",
      before    => [
        Service['pulp_celerybeat'],
        Service['pulp_resource_manager'],
        Service['pulp_workers'],
        Service['pulp_streamer'],
      ],
    }
    exec { 'pulp-manage-db-transition-to-new-touchfile':
      command => 'touch /var/lib/pulp/pulp-manage-db.init',
      user    => $pulp::http_user,
      path    => [
        'usr/local/bin',
        '/usr/bin',
        '/usr/local/sbin',
        '/usr/sbin',
      ],
      onlyif  => 'test -f /var/tmp/pulp-manage-db.init',
      before  => Exec['pulp-manage-db'],
    }
  }

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

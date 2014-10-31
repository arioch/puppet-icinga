# == Class: icinga::config::server::redhat
#
# This class provides server configuration for RHEL and derivative distro's.
#
class icinga::config::server::redhat {

  File {
    ensure  => present,
    owner   => $::icinga::server_user,
    group   => $::icinga::server_group,
    require => Class['icinga::config'],
    notify  => [
      Service[$::icinga::service_client],
      Service[$::icinga::service_server],
      Exec['fix_collected_permissions']
    ],
  }

  exec { 'fix_collected_permissions':
    # temporary work-around
    command     => "/bin/chown -R ${::icinga::server_user}:${::icinga::server_group} .",
    cwd         => $icinga::params::targetdir,
    notify      => Service[$::icinga::service_server],
    require     => File[$::icinga::targetdir],
    refreshonly => true,
  }

  file{$::icinga::icinga_vhost:
    content => template('icinga/redhat/httpd.conf.erb'),
    notify  => Service[$::icinga::service_webserver],
  }

  file{$::icinga::vardir_server:
    ensure => directory,
  }

  file{$::icinga::logdir_server:
    ensure => directory,
  }

  file{"${::icinga::confdir_server}/modules":
    ensure  => directory,
    recurse => true,
  }

  file{"${::icinga::targetdir}/notifications.cfg":
    content => template('icinga/redhat/notifications.cfg.erb'),
  }

  file{"${::icinga::targetdir}/templates.cfg":
    content => template('icinga/redhat/templates.cfg.erb'),
  }

  file{"${::icinga::confdir_server}/cgi.cfg":
    content => template('icinga/redhat/cgi.cfg.erb'),
  }

  file{"${::icinga::confdir_server}/icinga.cfg":
    content => template('icinga/redhat/icinga.cfg.erb'),
  }

  file{"${::icinga::logdir_server}/archives":
    ensure => directory,
  }

  file{"${::icinga::vardir_server}/rw":
    ensure => directory,
    group  => $::icinga::server_cmd_group,
  }

  file{"${::icinga::vardir_server}/rw/icinga.cmd":
    group => $::icinga::webserver_group,
  }

  file{"${::icinga::vardir_server}/checkresults":
    ensure => directory,
  }
}

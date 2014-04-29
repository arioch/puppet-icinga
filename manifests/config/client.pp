# == Class: icinga::config::client::common
#
# This class provides common client configuration.
#
class icinga::config::client {

  File {
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    notify  => Service[$::icinga::service_client],
    require => Class['icinga::install'],
  }

  file{$::icinga::confdir_client:
    ensure  => directory,
    recurse => true,
  }

  file{$::icinga::plugindir:
    ensure => directory,
  }

  file{"${::icinga::confdir_client}/nrpe.cfg":
    ensure  => present,
    content => template('icinga/common/nrpe.cfg.erb'),
  }

  file{$::icinga::logdir_client:
    ensure => directory,
  }

  file{$::icinga::includedir_client:
    ensure => directory,
  }

}

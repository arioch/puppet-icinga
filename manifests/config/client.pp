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

  # Make sure that /etc/nrpe.cfg is a symlink to ${::icinga::confdir_client}/nrpe.cfg on SLE12
  # This is done because we do not want to push a custom unit-file
  if $::operatingsystem == 'SLES' and $::operatingsystemmajrelease == '12' {
    file{'/etc/nrpe.cfg':
      ensure => link,
      target => "${::icinga::confdir_client}/nrpe.cfg",
      force  => true,
    }
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

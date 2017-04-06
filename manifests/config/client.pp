# == Class: icinga::config::client::common
#
# This class provides common client configuration.
#
class icinga::config::client {

  # Get the param in the local scope for the template
  $nrpe_command_prefix = $::icinga::nrpe_command_prefix

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

  if $::operatingsystemmajrelease  == '7' {
    file{'/etc/systemd/system/nrpe.service':
      ensure  => present,
      content => template('icinga/redhat/nrpe.service.erb'),
    }

    exec { 'systemctl-daemon-reload':
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      subscribe   => File['/etc/systemd/system/nrpe.service'],
      path        => $::path,
    }
  }
}

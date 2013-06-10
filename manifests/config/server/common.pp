class icinga::config::server::common {

  File {
    ensure  => 'directory',
    owner   => $::icinga::server_user,
    group   => $::icinga::server_group,
    notify  => [
      Service[$::icinga::service_client],
      Service[$::icinga::service_server],
    ],
  }

  file{$::icinga::confdir_server:
    recurse => true,
    purge   => true,
  }

  file{$::icinga::targetdir:
    recurse => true,
    purge   => true,
  }

  file{"${::icinga::targetdir}/hosts":
    recurse => true,
  }

  file{"${::icinga::sharedir_server}/bin":
    recurse => true,
  }

  file{"${::icinga::sharedir_server}/bin/sched_down.pl":
    ensure => 'present',
    source => 'puppet:///modules/icinga/sched_down.pl',
  }

  file{"${::icinga::targetdir}/hostgroups.cfg":
    ensure => 'present',
  }

  concat{"$::icinga::confdir_server/downtime.cfg":}
  concat::fragment {'header':
    target  => "$::icinga::confdir_server/downtime.cfg",
    order   => 0,
    content => "# Managed by Puppet\n",
  }

  file{"${::icinga::targetdir}/timeperiods.cfg":
    ensure => 'present',
  }

  file{"${::icinga::targetdir}/contacts":
    recurse => true,
  }

  file{"${::icinga::targetdir}/services":
    recurse => true,
  }

  file{"${::icinga::targetdir}/commands":
    recurse => true,
  }

  file{"${::icinga::sharedir_server}/images/logos":}

  file{"${::icinga::sharedir_server}/images/logos/os":
    recurse => true,
    source  => 'puppet:///modules/icinga/img-os',
  }

  file{$::icinga::htpasswd_file:
    ensure => 'present',
    mode   => '0644',
  }

  nagios_command {'schedule_script':
    command_line  => "${::icinga::sharedir_server}/bin/sched_down.pl \$ARG1\$",
    target        => "${::icinga::targetdir}/commands/schedule_script.cfg",
  }

  nagios_service {'schedule_downtimes':
    check_command       => 'schedule_script!-d0',
    service_description => 'schedule_downtimes',
    host_name           => "${::fqdn}",
    target              => "/etc/icinga/objects/services/${::fqdn}.cfg",
    check_period        => '24x7',
    check_interval      => '60',
    retry_interval      => '60',
  }
}

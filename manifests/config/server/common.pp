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

  file{"${::icinga::targetdir}/hostgroups.cfg":
    ensure => 'present',
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

}

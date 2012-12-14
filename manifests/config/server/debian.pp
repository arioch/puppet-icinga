# == Class: icinga::config::server::debian
#
# This class provides server configuration for Debian and derivative distro's.
#
class icinga::config::server::debian {

  File {
    ensure  => 'present',
    owner   => $::icinga::server_user,
    group   => $::icinga::server_group,
    notify  => [
      Service[$::icinga::service_client],
      Service[$::icinga::service_server],
      Group[$::icinga::server_cmd_group]
    ],
  }

  nagios_command{'check_nrpe_command':
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$',
    target       => "${::icinga::targetdir}/commands/check_nrpe_command.cfg",
  }

  file{$::icinga::icinga_vhost:
    content => template('icinga/debian/apache2.conf'),
    notify  => Service[$::icinga::service_webserver],
  }

  file{"${::icinga::confdir_server}/icinga.cfg":
    content => template('icinga/debian/icinga.cfg'),
  }

  file{"${::icinga::confdir_server}/cgi.cfg":
    content => template('icinga/debian/cgi.cfg'),
  }

  file{"${::icinga::confdir_server}/objects/generic-host_icinga.cfg":
    content => template('icinga/debian/objects/generic-host_icinga.cfg'),
  }

}

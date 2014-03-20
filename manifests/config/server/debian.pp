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
    ],
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

}

# == Class: icinga::install
#
# This class provides the main install selector.
#
class icinga::install {
  Package {
    require => Class['icinga::preinstall'],
  }

  if $::icinga::client {
    package { $::icinga::package_client:
      ensure => $::icinga::package_client_ensure;
    }
  }

  if $::icinga::server {
    package { $::icinga::package_server:
      ensure => $::icinga::package_server_ensure;
    }
  }
}

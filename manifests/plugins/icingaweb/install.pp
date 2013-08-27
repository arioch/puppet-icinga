# Class: icinga::plugins::icingaweb::install
#
# This class will install the icinga-web service
class icinga::plugins::icingaweb::install {
  package {
    $icinga::params::icingaweb_pkg_dep:
      ensure => 'latest';

    $icinga::params::icingaweb_pkg:
      ensure  => 'latest',
      require => Package[$icinga::params::icingaweb_pkg_dep];
  }
}

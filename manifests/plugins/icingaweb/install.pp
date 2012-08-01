class icinga::plugins::icingaweb::install {
  package {
    $icinga::icingaweb_pkg_dep:
      ensure => present;

    $icinga::icingaweb_pkg:
      ensure  => present,
      require => Package[$icinga::icingaweb_pkg_dep];
  }
}

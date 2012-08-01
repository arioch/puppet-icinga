class icinga::plugins::idoutils::install {
  package { $icinga::idoutils_pkg:
    ensure => present;
  }
}

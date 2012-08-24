# == Class: icinga::plugins::idoutils::install
#
# This class provides the idoutils plugin's installation.
#
class icinga::plugins::idoutils::install {
  package { $icinga::idoutils_pkg:
    ensure => present;
  }
}

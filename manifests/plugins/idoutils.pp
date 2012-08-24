# == Class: icinga::plugins::idoutils
#
# This class provides the idoutils plugin.
#
class icinga::plugins::idoutils {
  if $icinga::server {
    include icinga::plugins::idoutils::install
    include icinga::plugins::idoutils::config
    include icinga::plugins::idoutils::service

    Class['icinga::plugins::idoutils::install'] ->
    Class['icinga::plugins::idoutils::config'] ->
    Class['icinga::plugins::idoutils::service']
  }
}

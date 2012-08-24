# == Class: icinga::plugins::pnp4nagios
#
# This class provides the pnp4nagios plugin.
#
class icinga::plugins::pnp4nagios (
  $ensure = present
) {
  if $icinga::server {
    include icinga::plugins::pnp4nagios::install
    include icinga::plugins::pnp4nagios::config

    Class['icinga::plugins::pnp4nagios::install'] -> Class['icinga::plugins::pnp4nagios::config']
  }
}

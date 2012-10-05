# == Class: icinga::plugins::checkping
#
# This class provides a checkping plugin.
#
class icinga::plugins::checkping (
  $check_warning      = '',
  $check_critical     = '',
  $max_check_attempts = $::icinga::max_check_attempts
) inherits icinga {
  if $icinga::client {
    @@nagios_service { "check_ping_${::hostname}":
      check_command       => 'check_ping!100.0,20%!500.0,60%',
      service_description => 'Ping',
      host_name           => $::fqdn,
      max_check_attempts  => $max_check_attempts,
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}


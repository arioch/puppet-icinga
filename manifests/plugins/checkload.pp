# == Class: icinga::plugins::checkload
#
# This class provides a checkload plugin.
#
class icinga::plugins::checkload (
  $check_warning  = '',
  $check_critical = '',
  $max_check_attempts = $::icinga::max_check_attempts
) inherits icinga {
  if $icinga::client {
    @@nagios_service { "check_load_${::hostname}":
      check_command       => 'check_nrpe_command!check_load',
      service_description => 'Server load',
      host_name           => $::fqdn,
      max_check_attempts  => $max_check_attempts,
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    }
  }
}


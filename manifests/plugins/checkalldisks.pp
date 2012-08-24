# == Class: icinga::plugins::checkalldisks
#
# This class provides a checkalldisks plugin.
#
class icinga::plugins::checkalldisks (
  $check_warning  = '',
  $check_critical = ''
) inherits icinga {
  if $icinga::client {
    @@nagios_service { "check_all_disks_${::hostname}":
      check_command       => 'check_nrpe_command!check_all_disks',
      service_description => 'Disks',
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    }
  }
}


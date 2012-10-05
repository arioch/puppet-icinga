# == Class: icinga::plugins::checkiostatdisk
#
# This class provides a checkiostatdisk plugin.
#
class icinga::plugins::checkiostatdisk (
  $disk               = $name,
  $max_check_attempts = $::icinga::max_check_attempts
) inherits icinga {
  @@nagios_service { "check_iostat_${disk}_${::hostname}":
    check_command       => "check_nrpe_command!check_iostat_${disk}",
    host_name           => $::fqdn,
    max_check_attempts  => $max_check_attempts,
    service_description => "iostat ${disk}",
    action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }
}


class icinga::plugins::checkiostatdisk (
  $disk               = $name,
  $max_check_attempts = '4'
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


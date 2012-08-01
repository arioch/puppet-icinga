class icinga::plugins::checkalldisks (
  $check_warning  = '',
  $check_critical = ''
) {
  if $icinga::client {
    @@nagios_service { "check_all_disks_${::hostname}":
      check_command       => 'check_nrpe_command!check_all_disks',
      service_description => 'Disks',
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    }
  }
}


class icinga::plugins::checkload (
  $check_warning  = '',
  $check_critical = ''
) {
  if $icinga::client {
    @@nagios_service { "check_load_${::hostname}":
      check_command       => 'check_nrpe_command!check_load',
      service_description => 'Server load',
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    }
  }
}


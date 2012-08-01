class icinga::plugins::checkping (
  $check_warning  = '',
  $check_critical = ''
) {
  if $icinga::client {
    @@nagios_service { "check_ping_${::hostname}":
      check_command       => 'check_ping!100.0,20%!500.0,60%',
      service_description => 'Ping',
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    }
  }
}


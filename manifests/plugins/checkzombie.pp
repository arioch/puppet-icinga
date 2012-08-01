class icinga::plugins::checkzombie (
  $check_warning  = '',
  $check_critical = ''
) {
  if $icinga::client {
    @@nagios_service { "check_zombie_procs_${::hostname}":
      check_command       => 'check_nrpe_command!check_zombie_procs',
      service_description => 'Zombie processes',
    }
  }
}


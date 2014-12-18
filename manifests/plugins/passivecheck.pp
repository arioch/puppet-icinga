class icinga::plugins::passivecheck(
  $services = undef,
){

  define passive_checks_from_array() {
    @@nagios_service{ "${title}-${::fqdn}":
      active_checks_enabled  => 0,
      check_freshness        => 0,
      notifications_enabled  => $::icinga::notifications_enabled,
      passive_checks_enabled => 1,
      service_description    => $title,
      host_name              => $::fqdn,
      use                    => 'generic-service',
      target                 => "${::icinga::targetdir}/services/${::fqdn}.cfg",
      check_command          => 'check_dummy!0',
    }
  }

  passive_checks_from_array { $services: }

}

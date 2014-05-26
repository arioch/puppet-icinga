# == Class: icinga::plugins::checktotalprocs
#
# This class provides a checktotalprocs plugin.
#
class icinga::plugins::checktotalprocs (
  $check_warning         = '',
  $check_critical        = '',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    @@nagios_service { "check_total_procs_${::fqdn}":
      check_command         => 'check_nrpe_command!check_total_procs',
      service_description   => 'Total processes',
      contact_groups        => $contact_groups,
      host_name             => $::fqdn,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

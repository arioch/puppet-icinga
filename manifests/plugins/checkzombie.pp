# == Class: icinga::plugins::checkzombie
#
# This class provides a checkzombie plugin.
#
class icinga::plugins::checkzombie (
  $check_warning         = '',
  $check_critical        = '',
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    @@nagios_service { "check_zombie_procs_${::fqdn}":
      check_command         => 'check_nrpe_command!check_zombie_procs',
      service_description   => 'Zombie processes',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

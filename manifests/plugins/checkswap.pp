# == Class: icinga::plugins::checkswap
#
# This class provides a checkssh plugin.
#
class icinga::plugins::checkswap (
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    @@nagios_service{"check_swap_${::fqdn}":
      check_command         => 'check_nrpe_command!check_swap',
      service_description   => 'Swap Usage',
      host_name             => $::fqdn,
      use                   => 'generic-service',
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

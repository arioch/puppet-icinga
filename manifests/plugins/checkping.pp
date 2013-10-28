# == Class: icinga::plugins::checkping
#
# This class provides a checkping plugin.
#
class icinga::plugins::checkping (
  $check_warning         = '',
  $check_critical        = '',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    @@nagios_service { "check_ping_${::fqdn}":
      check_command         => 'check_ping!100.0,20%!500.0,60%',
      service_description   => 'Ping',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      action_url            => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

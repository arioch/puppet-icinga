# == Class: icinga::plugins::checkiostatdisk
#
# This class provides a checkiostatdisk plugin.
#
class icinga::plugins::checkiostatdisk (
  $disk                  = $name,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {
  @@nagios_service { "check_iostat_${disk}_${::fqdn}":
    check_command         => "check_nrpe_command!check_iostat_${disk}",
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    service_description   => "iostat ${disk}",
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    action_url            => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }
}


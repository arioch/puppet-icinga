# == Define: icinga::plugins::passivecheck
#
# This define provides a passivecheck plugin.
#
# Usage:
#   $services = [ 'collectd', 'crond' ]
#   icinga::plugins::passivecheck { $services:}

define icinga::plugins::passivecheck(
  $service_description = $title,
  $unique_id           = "${title}-${::fqdn}",
  $freshness_threshold = 3600,
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
){

  @@nagios_service{ $unique_id:
    active_checks_enabled  => 0,
    check_freshness        => 1,
    freshness_threshold    => $freshness_threshold,
    notifications_enabled  => $notifications_enabled,
    notification_period    => $notification_period,
    contact_groups         => $contact_groups,
    passive_checks_enabled => 1,
    service_description    => $service_description,
    host_name              => $::fqdn,
    use                    => 'generic-service',
    target                 => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    check_command          => "check_dummy!0 \"check was refreshed after \
${freshness_threshold} seconds\"",
  }

}

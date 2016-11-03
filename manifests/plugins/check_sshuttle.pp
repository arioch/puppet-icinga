# == Class: icinga::plugins::check_sshuttle
#
# This class provides a check_sshuttle plugin.
#
define icinga::plugins::check_sshuttle (
  $host,
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
  $port                         = 22,
  $subnets                      = [],
) {
  require ::icinga

  @@nagios_service { "check_sshuttle_tunnel_${::fqdn}_${name}":
    check_command         => "check_tcp_other_host!${host}!${port}! -e SSH",
    service_description   => "sshuttle tunnel - ${name}",
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    max_check_attempts    => $max_check_attempts,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}


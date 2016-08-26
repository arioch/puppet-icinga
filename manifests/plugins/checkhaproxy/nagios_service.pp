# == Define: icinga::plugins::checkhaproxy
#
# This define exports all IP addresses we want
# to check.
#
define icinga::plugins::checkhaproxy::nagios_service (
  $contact_groups,
  $max_check_attempts,
  $notification_period,
  $notifications_enabled,
  $target,
  $url_to_check = $title,
) {

  @@nagios_service { "check_haproxy_${::fqdn}_${url_to_check}":
    check_command         => "check_nrpe_command_args!check_haproxy!'${url_to_check}'",
    service_description   => "HAproxy check on ${url_to_check}",
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    max_check_attempts    => $max_check_attempts,
    target                => $target,
  }

}

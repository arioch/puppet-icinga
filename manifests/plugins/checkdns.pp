# == Class: icinga::plugins::checkssh
#
# This class provides a checkssh plugin.
#
class icinga::plugins::checkdns (
  $dnsname,
  $expected_answer,
  $notification_period   = $::icinga::notification_period,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    @@nagios_service { "check_dns_${::fqdn}_${dnsname}":
      check_command         => "check_dns!-H ${dnsname} -a ${expected_answer}",
      service_description   => "DNS - ${dnsname}",
      host_name             => $::fqdn,
      notification_period   => $notification_period,
      max_check_attempts    => $max_check_attempts,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

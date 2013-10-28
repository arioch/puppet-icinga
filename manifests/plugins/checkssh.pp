# == Class: icinga::plugins::checkssh
#
# This class provides a checkssh plugin.
#
class icinga::plugins::checkssh (
  $sshport               = '22',
  $check_warning         = '',
  $check_critical        = '',
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    @@nagios_service { "check_ssh_${::fqdn}":
      check_command         => "check_ssh!-p ${sshport}",
      service_description   => 'SSH',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      max_check_attempts    => $max_check_attempts,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

# == Class: icinga::plugins::checkntp
#
# This class provides a check_ntp plugin.
#
class icinga::plugins::checkntp (
  $ntp_server            = 'pool.ntp.org',
  $warn_value            = '1',
  $crit_value            = '10',
  $timeout               = '30',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits ::icinga {

  if is_array($ntp_server) {
    $_ntp_server = $ntp_server[0]
  } else {
    $_ntp_server = $ntp_server
  }

  require ::ntp

  file{"${::icinga::includedir_client}/ntp.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_ntp_time]=${::icinga::usrlib}/nagios/plugins/check_ntp_time -q -H ${_ntp_server} -w ${warn_value} -c ${crit_value} -t ${timeout}\n",
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service{"check_ntp_time_${::fqdn}":
    check_command         => 'check_nrpe_command!check_ntp_time',
    service_description   => 'NTP Time Drift',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

# == Class: icinga::plugins::checkntpdhealth
#
# This class provides a check_ntpd_health plugin.
#
class icinga::plugins::checkntpdhealth (
  $warn_value            = '75',
  $crit_value            = '50',
  $peer_warning          = '2',
  $peer_critical         = '1',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits ::icinga {

  require ::ntp

  $script_path = "${::icinga::plugindir}/check_ntpd_health.pl"

  file { $script_path:
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/icinga/check_ntpd_health.pl',
    notify => Service[$icinga::service_client],
  }

  file{"${::icinga::includedir_client}/ntpd_health.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_ntpd_health]=${script_path} -w ${warn_value} \
-c ${crit_value} --peer_critical ${peer_critical} \
--peer_warning ${peer_warning}\n",
    notify  => Service[$::icinga::service_client],
    require => File[$script_path],
  }

  @@nagios_service{"check_ntpd_health_${::fqdn}":
    check_command         => 'check_nrpe_command!check_ntpd_health',
    service_description   => 'NTPd health',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

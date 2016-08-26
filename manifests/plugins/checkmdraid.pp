# == Class: icinga::plugins::checkmdraid
#
# This class provides a md raid plugin.
#
class icinga::plugins::checkmdraid (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
) inherits icinga {

  file { "${::icinga::plugindir}/check_md_raid":
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/icinga/check_md_raid',
    notify  => Service[$icinga::service_client],
    require => Class['icinga::config'];
  }

  file { "${::icinga::includedir_client}/check_md_raid.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => template('icinga/plugins/check_md_raid.cfg.erb'),
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service { "check_md_raid_${::fqdn}":
    check_command         => 'check_nrpe_command!check_md_raid',
    service_description   => 'Software raid',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    max_check_attempts    => $max_check_attempts,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

# == Class: icinga::plugins::checkgluster
#
# This class provides a checkgluster plugin.
#
class icinga::plugins::checkgluster (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
) inherits icinga {

  file { "${::icinga::plugindir}/check_gluster.sh":
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/icinga/check_gluster.sh',
    notify  => Service[$icinga::service_client],
    require => Class['icinga::config'];
  }
  file { "${::icinga::includedir_client}/check_gluster.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => template('icinga/plugins/gluster.cfg.erb'),
    notify  => Service[$::icinga::service_client],
  }



  @@nagios_service { "check_gluster_${::fqdn}":
    check_command         => 'check_nrpe_command!check_gluster',
    service_description   => 'check gluster',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    max_check_attempts    => $max_check_attempts,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

  sudo::conf{'gluster_check_conf':
  content => "Defaults:nagios !requiretty
  nagios ALL=(ALL) NOPASSWD:/usr/sbin/gluster *\n",
  }

}


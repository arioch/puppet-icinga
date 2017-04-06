# == Class: icinga::plugins::checkhaproxy
#
# This class only creates proper NRPE config with command 'check_haproxy' but
# the exported resource is defined in icinga::plugins::checkhaproxy::nagios_service
#
#
class icinga::plugins::checkhaproxy (
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
  $target                = "${::icinga::targetdir}/services/${::fqdn}.cfg",
) inherits icinga {

  file { "${::icinga::plugindir}/check_haproxy.rb":
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/icinga/check_haproxy.rb',
    notify  => Service[$icinga::service_client],
    require => Class['icinga::config'];
  }

  file { "${::icinga::includedir_client}/haproxy.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => template('icinga/plugins/haproxy.cfg.erb'),
    notify  => Service[$::icinga::service_client],
  }

}

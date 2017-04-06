# == Class: icinga::plugins::check_dns_sync
#
# This class provides a check_dns_sync plugin.
#
class icinga::plugins::check_dns_sync (
  $icinga_host,
  $ensure                = present,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = 'workhours',
  $notifications_enabled = $::icinga::notifications_enabled,
  $full_zonelist         = {},
  $ignored_domains       = undef,
) inherits icinga {

  package { 'perl-Net-DNS.x86_64':
    ensure => present,
  }

  package { 'perl-Net-IP.noarch':
    ensure => present,
  }

  package { 'nsca-client':
    ensure => present,
  }

  file { "${::icinga::plugindir}/check_dns_sync.pl":
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/icinga/check_dns_sync.pl',
    notify  => Service[$icinga::service_client],
    require => Class['icinga::config'];
  }
  file { "${::icinga::plugindir}/dns_sync.sh":
    ensure  => 'file',
    mode    => '0755',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => template('icinga/plugins/dns_sync.sh.erb'),
  }

  cron { 'dns sync check':
    ensure  => present,
    command => "${::icinga::plugindir}/dns_sync.sh",
    user    => 'root',
    minute  => '*/10',
  }

  @@nagios_service { "check_dns_sync_${::fqdn}":
    check_command         => 'check_dummy!0 "All ok"',
    active_checks_enabled => '0',
    freshness_threshold   => '600',
    service_description   => 'dns sync',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    max_check_attempts    => $max_check_attempts,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

# == Class: icinga::plugins::check_es_unassigned_shards
class icinga::plugins::check_es_unassigned_shards (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $host                         = 'localhost',
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,

) inherits icinga {
  file{"${::icinga::includedir_client}/check_es_unassigned_shards.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_es_unassigned_shards]=${::icinga::plugindir}/check_es-unassigned-shards.py --host=${host} ",
    notify  => Service[$::icinga::service_client],
  }

  package { 'nagios-plugins-es-unassigned-shards':
    ensure => 'present',
  }

  @@nagios_service{"check_es_unassigned_shards_${::fqdn}":
    check_command         => 'check_nrpe_command!check_es_unassigned_shards',
    service_description   => "Check ElasticSearch Unassigned Shards  Status ${::fqdn}",
    host_name             => $::fqdn,
    contact_groups        => $::environment,
    use                   => 'generic-service',
    notification_period   => $::icinga::notification_period,
    notifications_enabled => $::icinga::notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }
}

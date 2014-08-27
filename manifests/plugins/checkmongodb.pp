# == Class: icinga::plugins::checkmongodb
#
# This class provides a checkmongodb plugin.
#
class icinga::plugins::checkmongodb (
  $ensure                = present,
  $perfdata              = true,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,

) inherits icinga {
  if $icinga::client {
    if !defined(Package['python-pip']) {
      package { 'python-pip':
        ensure => present,
      }
    }

    if !defined(Package['pymongo']) {
      package { 'pymongo':
        ensure => present,
        provider => 'pip',
        require => Package['python-pip'],
      }
    }

    file { "${::icinga::plugindir}/check_mongodb.py":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source => 'puppet:///modules/icinga/check_mongodb.py',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file { "${::icinga::includedir_client}/mongodb.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/mongodb.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_mongodb_replication_lag_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mongodb!replication_lag!27017!15!30',
      service_description   => 'MongoDB Replication Lag',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_mongodb_replication_lag_percentage_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mongodb!replication_lag_percent!27017!50!75',
      service_description   => 'MongoDB Replication Lag Percentage',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_mongodb_replicaset_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mongodb_replicaset!replica_primary!27017!0!1!your-replicaset',
      service_description   => 'MongoDB Replicaset',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}

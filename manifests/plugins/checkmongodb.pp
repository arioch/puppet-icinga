# == Class: icinga::plugins::checkmongodb
#
# This class provides a checkmongodb plugin.
#
class icinga::plugins::checkmongodb (
  $ensure                       = present,
  $perfdata                     = true,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
  $mongod_bind_ip               = '127.0.0.1',
  $mongod_graphite_io_read_url  = 'http://graphite/render?target=mongo_host.processes.mongod.ps_disk_octets.read&from=-5minutes&rawData=true',
  $mongod_graphite_io_write_url = 'http://graphite/render?target=mongo_host.processes.mongod.ps_disk_octets.write&from=-5minutes&rawData=true',
  $graphite_host                = undef,
) inherits icinga {

  if $icinga::client {
    if !defined(Package['python-pip']) {
      package { 'python-pip':
        ensure => present,
      }
    }

    if !defined(Package['pymongo']) {
      package { 'pymongo':
        ensure   => present,
        provider => 'pip',
        require  => Package['python-pip'],
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
      check_command         => 'check_nrpe_command!check_mongodb_replication_lag',
      service_description   => 'MongoDB Replication Lag',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_mongodb_replication_lag_percentage_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mongodb_replication_lag_percentage',
      service_description   => 'MongoDB Replication Lag Percentage',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_mongodb_replicaset_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mongodb_replicaset',
      service_description   => 'MongoDB Replicaset',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_mongodb_connect_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mongodb_connect',
      service_description   => 'MongoDB Connection Time',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_mongodb_connections_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mongodb_connections',
      service_description   => 'MongoDB Connections Percentage',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_mongodb_replset_state_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mongodb_replset_state',
      service_description   => 'MongoDB Replication State',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    if $graphite_host != undef {
      @@nagios_service{"check_mongod_io_read_operations${::fqdn}":
        check_command         => "check_graphite!${mongod_graphite_io_read_url}!10000000!50000000",
        service_description   => 'MongoDB IO Read Operations',
        host_name             => $::fqdn,
        use                   => 'generic-service',
        contact_groups        => $contact_groups,
        notification_period   => $notification_period,
        notifications_enabled => $notifications_enabled,
        target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
      }

      @@nagios_service{"check_mongod_io_write_operations${::fqdn}":
        check_command         => "check_graphite!${mongod_graphite_io_write_url}!10000000!50000000",
        service_description   => 'MongoDB IO Write Operations',
        host_name             => $::fqdn,
        use                   => 'generic-service',
        contact_groups        => $contact_groups,
        notification_period   => $notification_period,
        notifications_enabled => $notifications_enabled,
        target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
      }
    }
  }
}

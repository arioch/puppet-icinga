# == Class: icinga::plugins::check_zimbra_snapshot
#
# This class provides a check_zimbra_snapshot plugin.
#
class icinga::plugins::check_zimbra_snapshot (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,

) inherits icinga {


    file { "${::icinga::plugindir}/zimbra_snapshot.rb":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source => 'puppet:///modules/icinga/zimbra_snapshot.rb',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }
    file { "${::icinga::includedir_client}/zimbra_snapshot.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/zimbra_snapshot.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }



    @@nagios_service { "check_zimbra_snapshot_${::fqdn}":
      check_command         => 'check_nrpe_command!check_zimbra_snapshot',
      service_description   => 'zimbra snapshot',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

  }


# == Class: icinga::plugins::checkmdsbackend
#
# This class provides a checkmdsbackend plugin.
#
class icinga::plugins::checkmdsbackend (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
  $mediamosa_vhost_name         = hiera('mediamosa_vhost_name'),
) inherits icinga {

    file { "${::icinga::plugindir}/mds_backend.rb":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/icinga/mds_backend.rb',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }
    file { "${::icinga::includedir_client}/mds_backend.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/mds_backend.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }



    @@nagios_service { "mds_backend_${::fqdn}":
      check_command         => 'check_nrpe_command!mds_backend',
      service_description   => 'mds-backend',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }


  }

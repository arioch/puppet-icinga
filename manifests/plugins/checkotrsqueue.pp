# == Class: icinga::plugins::checkotrsqueue 
#
# This class provides a checkotrsqueue plugin.
#
class icinga::plugins::checkotrsqueue (
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
  $mysql_otrs_nagios_user       = 'nagios',
  $mysql_otrs_nagios_pass       = 'nagios',
  $mysql_otrs_host              = '127.0.0.1',
  $mysql_otrs_db                = 'otrs',
  $check_warning                = '1',
  $check_critical               = '2',
) inherits icinga {

  if $icinga::client {
    file { "${::icinga::plugindir}/check_otrs_queue.pl":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/icinga/check_otrs_queue.pl',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file { "${::icinga::includedir_client}/check_otrs_queue.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/check_otrs_queue.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_otrs_queue_${::fqdn}":
      check_command         => 'check_nrpe_command!check_otrs_queue',
      service_description   => 'OTRS queue',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}


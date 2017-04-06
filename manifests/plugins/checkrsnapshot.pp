# == Class: icinga::plugins::checkrsnapshot
#
# This class provides a checkrsnapshot plugin.
#
class icinga::plugins::checkrsnapshot (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = 'workhours',
  $notifications_enabled        = $::icinga::notifications_enabled,
  $config                       = hiera('rsnapshot::params::config', $::rsnapshot::params::config),
  $logfile                      = '/var/log/rsnapshot',
  $crontabs                     = hiera('rsnapshot::params::crontabs', $::rsnapshot::params::crontabs),
) inherits icinga {

    $timeshift = $crontabs['daily']['hour']
    file { "${::icinga::plugindir}/check_rsnapshot.rb":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/icinga/check_rsnapshot.rb',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }
    file { "${::icinga::includedir_client}/check_rsnapshot.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/check_rsnapshot.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }



    @@nagios_service { "check_rsnapshot_${::fqdn}":
      check_command         => 'check_nrpe_command!check_rsnapshot',
      service_description   => 'rsnapshot backups',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }


  }

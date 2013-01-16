# == Class: icinga::plugins::checkbacula
#
# This class provides a checkbacula plugin.
#
class icinga::plugins::checkbacula (
  $pkgname               = 'nagios-plugins-bacula',
  $jobname               = $::fqdn,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    package{$pkgname:
      ensure => 'installed',
    }

    file{"${::icinga::includedir_client}/bacula.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_bacula]=${::icinga::plugindir}/check_bacula -j ${jobname} -w ${warning} -c ${critical}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_bacula_${::fqdn}":
      check_command         => 'check_nrpe_command!check_bacula',
      service_description   => 'Bacula Jobs',
      host_name             => $::fqdn,
      use                   => 'generic-service',
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

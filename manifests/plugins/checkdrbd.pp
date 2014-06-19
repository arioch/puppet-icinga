# == Class: icinga::plugins::checkdrbd
#
# This class provides a checkdrbd plugin.
#
class icinga::plugins::checkdrbd (
  $pkgname                = $::operatingsystem ? {
    'centos' => 'nagios-plugins-drbd',
    'debian' => 'nagios-plugin-drbd',
  },
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $contact_groups         = $::environment,
) {

  require icinga

  if $icinga::client {

    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure => 'latest',
      }
    }

    file{"${::icinga::includedir_client}/check_drbd.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_drbd]=${::icinga::plugindir}/check_drbd\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_drbd_${host_name}_${title}":
      check_command         => 'check_nrpe_command!check_drbd',
      service_description   => 'DRBD',
      host_name             => $host_name,
      use                   => 'generic-service',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}

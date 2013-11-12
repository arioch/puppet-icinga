# == Class: icinga::plugins::checkcrm
#
# This class provides a checkcrm plugin.
#
# Checks pacemaker
#
define icinga::plugins::checkcrm (
  $pkgname                = $::operatingsystem ? {
    'centos' => ['nagios-plugins-check-crm','perl-Nagios-Plugin'],
    default  => fail('Unsupported operatingsystem'),
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

    file{"${::icinga::includedir_client}/check_crm_${host_name}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_crm_${host_name}]=${::icinga::plugindir}/check_crm\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_crm_${host_name}":
      check_command         => "check_nrpe_command!check_crm_${host_name}",
      service_description   => 'Pacemaker',
      host_name             => $host_name,
      use                   => 'generic-service',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}
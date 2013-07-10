# == Class: icinga::plugins::checkmediasalsabackup
#
# This class provides a checkmediasalsabackup plugin.
#
# Warning and Critical expressed in number of missing backups
define icinga::plugins::checkmediasalsabackup (
  $pkgname                = $::operatingsystem ? {
    'centos' => 'nagios-plugins-checkmediasalsabackup',
    'debian' => 'nagios-plugin-checkmediasalsabackup',
  },
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $backup_location,
  $warning                = '1',
  $critical               = '2',
) {

  require icinga

  if $icinga::client {

    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure => 'latest',
      }
    }

    file{"${::icinga::includedir_client}/check_mediasalsa_backup_${title}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_mediasalsa_backup_${title}]=sudo ${::icinga::plugindir}/check_mediasalsa_backup -p ${backup_location} -w ${warning} -c ${critical}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_mediasalsa_backup_${host_name}_${title}":
      check_command         => "check_nrpe_command!check_mediasalsa_backup_${title}",
      service_description   => "Check Mediasalsa Backups",
      host_name             => $host_name,
      use                   => 'generic-service',
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}

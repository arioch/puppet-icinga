# == Class: icinga::plugins::checkmailman
#
# This class provides a check-mailman plugin.
#
# Warning and Critical expressed in minutes.
define icinga::plugins::checkmailman (
  $pkgname                = $::operatingsystem ? {
    'centos' => 'nagios-plugins-check-mailman',
    'debian' => 'nagios-plugin-check-mailman',
  },
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $contact_groups         = $::environment,
  $warning                = '15',
  $critical               = '30',
  $dir                    = '/var/spool/mailman',
  $queue                  = 'out',
) {

  require icinga

  if $icinga::client {

    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure => 'latest',
      }
    }

    file{"${::icinga::includedir_client}/check_mailman_${title}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_mailman_${title}]=${::icinga::plugindir}/check_mailman -d ${dir} -q ${queue} -w ${warning} -c ${critical}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_mailman_${host_name}_${title}":
      check_command         => "check_nrpe_command!check_mailman_${title}",
      service_description   => "Check Mailman - ${queue} queue",
      host_name             => $host_name,
      use                   => 'generic-service',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}

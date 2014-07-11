# == Class: icinga::plugins::checklengthydrupalcron
#
# This class provides a checklengthydrupalcron plugin.
#
# All processes containing cron.php will be matched assuming it's a drupal site
#
# Warning and Critical expressed in seconds.  3600sec = 1h, 7200sec = 2h
define icinga::plugins::checklengthydrupalcron (
  $pkgname                = $::operatingsystem ? {
    'centos' => 'nagios-plugins-procs',
    'debian' => 'nagios-plugins-basic',
  },
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $contact_groups         = $::environment,
  $warning                = '1800',
  $critical               = '3600',
) {

  require icinga

  if $icinga::client {

    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure => 'latest',
      }
    }

    file{"${::icinga::includedir_client}/check_lengthy_drupal_cron_${host_name}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_lengthy_drupal_cron_${host_name}]=${::icinga::plugindir}/check_procs -m ELAPSED --ereg-argument-array='(\/cron.php|drush cron)' -w ${warning} -c ${critical}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_lengthy_drupal_cron_${host_name}_${host_name}":
      check_command         => "check_nrpe_command!check_lengthy_drupal_cron_${host_name}",
      service_description   => 'Long Running Drupal Cron',
      host_name             => $host_name,
      use                   => 'generic-service',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}

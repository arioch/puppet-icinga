# == Class: icinga::plugins::checkdrupalcron
#
# This class provides a checkdrupalcron plugin.
#
# Warning and Critical expressed in seconds.  3600sec = 1h, 7200sec = 2h
define icinga::plugins::checkdrupalcron (
  $pkgname                = $::operatingsystem ? {
    'centos' => 'nagios-plugins-drupal-cron',
    'debian' => 'nagios-plugins-drupal-cron',
  },
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $contact_groups         = $::environment,
  $use_sudo               = true,
  $warning                = '3600',
  $critical               = '7200',
  $uri                    = '',
  $root                   = '',
) {

  require icinga

  if $icinga::client {

    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure => 'latest',
      }
    }

    if $use_sudo {
      $content="command[check_drupal_cron_${title}]=sudo ${::icinga::plugindir}/check_drupal-cron -u ${uri} -r ${root} -w ${warning} -c ${critical}\n"
    }
    else {
      $content="command[check_drupal_cron_${title}]=${::icinga::plugindir}/check_drupal-cron -u ${uri} -r ${root} -w ${warning} -c ${critical}\n"
    }

    file{"${::icinga::includedir_client}/check_drupal_cron_${title}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => $content,
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_drupal_cron_${host_name}_${title}":
      check_command         => "check_nrpe_command!check_drupal_cron_${title} -t 120",
      service_description   => "Drupal Cron ${title}",
      host_name             => $host_name,
      use                   => 'generic-service',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}

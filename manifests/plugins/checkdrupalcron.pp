# == Class: icinga::plugins::checkdrupalcron
#
# This class provides a checkdrupalcron plugin.
#
# Warning an Critial expressed in seconds.  3600sec = 1h, 7200sec = 2h
class icinga::plugins::checkdrupalcron (
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $uri                    = undef,
  $root                   = undef,
  $warning_after_seconds  = '3600',
  $critical_after_seconds = '7200',
) inherits icinga {

  if $icinga::client {
    package{$pkgname:
      ensure => 'installed',
    }

    file{"${::icinga::includedir_client}/check_drupal_cron.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_drupal_cron]=${::icinga::plugindir}/check_drupal_cron ${uri} ${root} ${warning_after_seconds} ${critical_after_seconds}\n",
      notify  => Service[$::icinga::service_client],
    }
  }
}
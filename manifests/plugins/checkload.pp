# == Class: icinga::plugins::checkload
#
# This class provides a checkload plugin.
#
class icinga::plugins::checkload (
  $pkgname               = 'nagios-plugins-load',
  $check_warning         = '15,10,5',
  $check_critical        = '30,25,20',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    if $::osfamily != 'Debian' {
      package{$pkgname:
        ensure => 'installed',
      }
    }

    file{"${::icinga::includedir_client}/load.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_load]=${::icinga::plugindir}/check_load -w ${check_warning} -c ${check_critical}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_load_${::fqdn}":
      check_command         => 'check_nrpe_command!check_load',
      service_description   => 'Server load',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
      action_url            => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    }
  }

}

# == Class: icinga::plugins::checkload
#
# This class provides a checkload plugin.
#
class icinga::plugins::checkload (
  $pkgname               = 'nagios-plugins-load',
  $check_warning         = hiera('nagios_load_warning', undef),
  $check_critical        = hiera('nagios_load_critical', undef),
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

    if !$check_warning {
      $warn_1 = $::processorcount * 3
      $warn_5 = $::processorcount * 2
      $warn_15 = $::processorcount + 1
      $_check_warning = "${warn_1},${warn_5},${warn_15}"
    } else {
      $_check_warning = $check_warning
    }

    if !$check_critical {
      $crit_1 = $::processorcount * 5
      $crit_5 = $::processorcount * 4
      $crit_15 = $::processorcount * 3
      $_check_critical = "${crit_1},${crit_5},${crit_15}"
    } else {
      $_check_critical = $check_critical
    }

    file{"${::icinga::includedir_client}/load.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_load]=${::icinga::plugindir}/check_load -w ${_check_warning} -c ${_check_critical}\n",
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
    }
  }

}

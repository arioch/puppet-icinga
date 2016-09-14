# == Class: icinga::plugins::checkvufwatcher
#
# This class provides a checkvufwatcher plugin.
#
class icinga::plugins::checkvufwatcher (
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    file{"${::icinga::includedir_client}/vufwatcher.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_vufwatcher]=${::icinga::plugindir}/check_procs -c 1: -C python --argument-array=vufwatcher.py\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_vufwatcher_${::fqdn}":
      check_command         => 'check_nrpe_command!check_vufwatcher',
      service_description   => 'Vufwatcher',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

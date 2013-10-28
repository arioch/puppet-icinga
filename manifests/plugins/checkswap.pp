# == Class: icinga::plugins::checkswap
#
# This class provides a checkssh plugin.
#
class icinga::plugins::checkswap (
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    file{"${::icinga::includedir_client}/swap.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_swap]=${::icinga::plugindir}/check_swap -w 50% -c 25%\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_swap_${::fqdn}":
      check_command         => 'check_nrpe_command!check_swap',
      service_description   => 'Swap Usage',
      host_name             => $::fqdn,
      use                   => 'generic-service',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

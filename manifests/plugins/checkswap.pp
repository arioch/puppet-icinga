# == Class: icinga::plugins::checkswap
#
# This class provides a checkssh plugin.
#
class icinga::plugins::checkswap (
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    file{"${::icinga::includedir_client}/swap.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_swap]=<%= scope.lookupvar('icinga::plugindir') %>/check_swap -w 50% -c 25%\n",
    }

    @@nagios_service{"check_swap_${::fqdn}":
      check_command         => 'check_nrpe_command!check_swap',
      service_description   => 'Swap Usage',
      host_name             => $::fqdn,
      use                   => 'generic-service',
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

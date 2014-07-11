# == Class: icinga::plugins::checkcron
#
# This class provides a checkcron plugin.
#
class icinga::plugins::checkcron (
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {

    $cron_proc_name = $::osfamily ? {
        'Debian'    => 'cron',
        'RedHat'    => 'crond',
        default     => 'crond',
    }

    file{"${::icinga::includedir_client}/cron.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_cron]=${::icinga::plugindir}/check_procs -c 1: -C ${cron_proc_name}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_cron_${::fqdn}":
      check_command         => 'check_nrpe_command!check_cron',
      service_description   => 'Cron',
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

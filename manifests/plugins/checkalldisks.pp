# == Class: icinga::plugins::checkalldisks
#
# This class provides a checkalldisks plugin.
#
class icinga::plugins::checkalldisks (
  $check_warning         = '10%',
  $check_critical        = '5%',
  $max_check_attempts    = $::icinga::max_check_attempts,
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    file{"${::icinga::includedir_client}/all_disks.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_all_disks]=sudo ${::icinga::plugindir}/check_disk -w ${check_warning} -c ${check_critical} -W ${check_warning} -C ${check_critical}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_all_disks_${::fqdn}":
      check_command         => 'check_nrpe_command!check_all_disks',
      service_description   => 'Disks',
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

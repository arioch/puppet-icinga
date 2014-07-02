# == Class: icinga::plugins::checkmegaraid
#
# This class provides a checkmegaraid plugin.
#
class icinga::plugins::checkmegaraid (
  $bin_path                       = '/usr/sbin/MegaCli64',
  $hotspare_count                 = '0',
  $media_errors_ignore_count      = '0',
  $predictive_errors_ignore_count = '0',
  $other_disk_errors_ignore_count = '0',
  $max_check_attempts             = $::icinga::max_check_attempts,
  $contact_groups                 = $::environment,
  $notification_period            = $::icinga::notification_period,
  $notifications_enabled          = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    file{"${::icinga::includedir_client}/megaraid.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_megaraid]=sudo ${::icinga::plugindir}/check_megaraid_sas -s ${hotspare_count} -m ${media_errors_ignore_count} -p ${predictive_errors_ignore_count} -o ${other_disk_errors_ignore_count}\n",
      notify  => Service[$::icinga::service_client],
    }

    file{"${::icinga::plugindir}/check_megaraid_sas":
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('icinga/plugins/check_megaraid_sas.erb'),
    }

    @@nagios_service { "check_megaraid_${::fqdn}":
      check_command         => 'check_nrpe_command!check_megaraid',
      service_description   => 'MegaRaid',
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

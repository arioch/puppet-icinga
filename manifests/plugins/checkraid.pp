# Class: icinga::plugins::checkraid
#
#
class icinga::plugins::checkraid (
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) {

  require ::icinga

  if $icinga::client {
    package{'nagios-plugins-linux_raid':
      ensure => 'present',
    }

    file { "${::icinga::includedir_client}/check_linux_raid_${::fqdn}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_linux_raid]=${::icinga::plugindir}/check_linux_raid\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_linux_raid_${::fqdn}":
      check_command         => 'check_nrpe_command!check_linux_raid',
      service_description   => 'RAID',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}


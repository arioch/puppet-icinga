# == Class: icinga::plugins::checkmailq
#
# This class provides a checkmailq plugin.
#
class icinga::plugins::checkmailq (
  $pkgname               = 'nagios-plugins-mailq',
  $check_warning         = '5',
  $check_critical        = '10',
  $mailserver_type       = 'postfix',
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

    file{"${::icinga::includedir_client}/mailq.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_mailq]=sudo ${::icinga::plugindir}/check_mailq -w ${check_warning} -c ${check_critical} -M ${mailserver_type}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_mailq_${::fqdn}":
      check_command         => 'check_nrpe_command!check_mailq',
      service_description   => 'Mailqueue',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

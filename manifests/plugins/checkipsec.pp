# == Class: icinga::plugins::checkipsec
#
# This class provides the check_ipsec plugin.
#
class icinga::plugins::checkipsec (
  $pkgname               = 'nagios-plugins-ipsec',
  $tunnels               = '1',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) {

  package{$pkgname:
    ensure => 'installed',
  }

  sudo::conf{'icinga_nrpe_check_ipsec':
    content => "${::icinga::client_user} ALL=(ALL) NOPASSWD:/usr/lib/nagios/plugins/check_ipsec,/usr/lib64/nagios/plugins/check_ipsec\n",
  }

  file{"${::icinga::includedir_client}/ipsec.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_ipsec]=sudo ${::icinga::usrlib}/nagios/plugins/check_ipsec --tunnels ${tunnels}\n",
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service{"check_ipsec_tunnels_${::fqdn}":
    check_command         => 'check_nrpe_command!check_ipsec',
    service_description   => 'IPsec tunnels',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

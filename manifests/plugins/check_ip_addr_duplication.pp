# == Class: icinga::plugins::check_ip_addr_duplication
#
# This class provides a check_ip_addr_duplication plugin.
#
class icinga::plugins::check_ip_addr_duplication (
  $max_check_attempts    = $::icinga::max_check_attempts,
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
  $additional_options    = '',
) inherits icinga {

  file{"${::icinga::includedir_client}/check_ip_addr_duplication.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_ip_addr_duplication]=sudo ${::icinga::plugindir}/ip_address_duplication_check.sh\n",
    notify  => Service[$::icinga::service_client],
  }

  file{"${::icinga::plugindir}/ip_address_duplication_check.sh":
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/icinga/ip_address_duplication_check.sh',
    notify  => Service[$icinga::service_client],
    require => Class['icinga::config'];
  }

  @@nagios_service { "check_ip_addr_duplication_${::fqdn}":
    check_command         => 'check_nrpe_command!check_ip_addr_duplication',
    service_description   => 'IP duplicates',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

  sudo::conf{'configure_sudo_check_ip_addr_duplication':
    content => "#managed by puppetDefaults:${::icinga::client_user} !requiretty\n
${::icinga::client_user} ALL=(ALL) NOPASSWD:${::icinga::plugindir}/ip_address_duplication_check.sh\n",
  }
}

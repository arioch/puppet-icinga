# == Class: icinga::plugins::checksslscan
#
# This class provides a checksslscan plugin.
#
class icinga::plugins::checksslscan (
  $host_url              = undef,
  $host_ip               = undef,
  $warning_grade         = 'B',
  $critical_grade        = 'C',
  $publish_results       = false,
  $accept_cached_results = true,
  $max_cache_age         = undef,
  $debug_mode            = false,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
  $additional_options    = '',
) inherits icinga {

  validate_string($host_url)
  validate_string($warning_grade)
  validate_string($critical_grade)
  validate_bool($publish_results)
  validate_bool($accept_cached_results)
  validate_bool($debug_mode)

  $_publish_results = ''
  $_accept_cached_results = ''
  $_debug_mode = ''
  $_max_cache_age = ''
  $_ip_address = ''

  if $publish_results {
    $_publish_results = '-p '
  }
  if $accept_cached_results {
    $_accept_cached_results = '-x '
  }
  if $debug_mode {
    $_debug_mode = '-d'
  }
  if $max_cache_age {
    $_max_cache_age = "-a ${max_cache_age} "
  }
  if $host_ip {
    $_ip_address = "-ip ${host_ip} "
  }

  if $icinga::client {
    file { "${::icinga::plugindir}/check_sslscan.pl":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/icinga/check_sslscan.pl',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file{"${::icinga::includedir_client}/check_sslscan.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_sslscan]=${::icinga::plugindir}/check_sslscan.pl -H ${host_name} -w ${warning_grade} -c ${critical_grade} ${_publish_results}${_accept_cached_results}${_max_cache_age}${_ip_address}${_debug_mode}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_all_disks_${::fqdn}_${host_name}":
      check_command         => 'check_nrpe_command!check_all_disks',
      service_description   => 'Disks',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

# == Class: icinga::plugins::checksslscan
#
# This defined type provides a checksslscan plugin.
#
define icinga::plugins::checksslscan (
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
) {

  require icinga

  validate_string($host_url)
  validate_string($warning_grade)
  validate_string($critical_grade)
  validate_bool($publish_results)
  validate_bool($accept_cached_results)
  validate_bool($debug_mode)

  if $publish_results {
    $_publish_results = '-p '
  } else {
    $_publish_results = ''
  }

  if $accept_cached_results == false {
    $_accept_cached_results = '-x '
  } else {
    $_accept_cached_results = ''
  }

  if $debug_mode {
    $_debug_mode = '-d'
  } else {
    $_debug_mode = ''
  }

  if $max_cache_age {
    $_max_cache_age = "-a ${max_cache_age} "
  } else {
    $_max_cache_age = ''
  }

  if $host_ip {
    $_ip_address = "-ip ${host_ip} "
  } else {
    $_ip_address = ''
  }

  if $icinga::client {

    # Only include this file once
    if (!defined(File["${::icinga::plugindir}/check_sslscan.pl"])) {
      file { "${::icinga::plugindir}/check_sslscan.pl":
        ensure  => present,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        source  => 'puppet:///modules/icinga/check_sslscan.pl',
        notify  => Service[$icinga::service_client],
        require => Class['icinga::config'];
      }
    }

    if (!defined(Package['perl-JSON'])) {
      package { 'perl-JSON':
        ensure => installed,
      }
    }

    if (!defined(Package['perl-Crypt-SSLeay'])) {
      package { 'perl-Crypt-SSLeay':
        ensure => installed,
      }
    }

    if (!defined(Package['perl-Net-SSLeay'])) {
      package { 'perl-Net-SSLeay':
        ensure => installed,
      }
    }

    file{"${::icinga::includedir_client}/check_sslscan_${host_url}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_sslscan_${host_url}]=${::icinga::plugindir}/check_sslscan.pl -H ${host_url} -w ${warning_grade} -c ${critical_grade} ${_publish_results}${_accept_cached_results}${_max_cache_age}${_ip_address}${_debug_mode}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_sslscan_${::fqdn}_${host_url}":
      check_command         => "check_nrpe_command_timeout!240!check_sslscan_${host_url}",
      check_interval        => '86400', # Every 12 hours is fine
      service_description   => "SSL Quality ${host_url}",
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

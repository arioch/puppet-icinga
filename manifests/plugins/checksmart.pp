# == Class: icinga::plugins::checksmart
#
# This class provides a checksmart plugin.
#
class icinga::plugins::checksmart (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
  $smart_devices                = hiera('smart_devices'),
) inherits icinga {

  package { 'smartmontools.x86_64':
    ensure => present,
  }


   file { "${::icinga::plugindir}/check_smart.rb":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source => 'puppet:///modules/icinga/check_smart.rb',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }
    file { "${::icinga::plugindir}/check_smart.pl":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source => 'puppet:///modules/icinga/check_smart.pl',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file { "${::icinga::includedir_client}/SMART.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/SMART.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }



    @@nagios_service { "check_smart_${::fqdn}":
      check_command         => 'check_nrpe_command!check_smart',
      service_description   => 'S.M.A.R.T.',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    sudo::conf{'check_smart':
    content => "Defaults:nagios !requiretty
    nagios ALL=(ALL) NOPASSWD:/usr/sbin/smartctl\n",
    }

  }


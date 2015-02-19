# == Class: icinga::plugins::checkipmi
#
# This class provides a checkhipmi plugin.
#
class icinga::plugins::checkipmi (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
  $ignored_sensors              = hiera('ignored_sensors', undef),
) inherits icinga {

   package { 'perl-IPC-Run.noarch':
      ensure => present,
   }

   package { 'freeipmi':
      ensure => present,
   }

   file { "${::icinga::plugindir}/check_ipmi_sensor":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source => 'puppet:///modules/icinga/check_ipmi_sensor',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }
    file { "${::icinga::includedir_client}/ipmi.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/ipmi.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }



    @@nagios_service { "check_ipmi_${::fqdn}":
      check_command         => 'check_nrpe_command!check_ipmi',
      service_description   => 'IPMI',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    sudo::conf{'ipmi_check_conf':
    content => "Defaults:nagios !requiretty
    nagios ALL=(ALL) NOPASSWD:/usr/sbin/ipmimonitoring,/usr/sbin/ipmi-sensors\n",
    }

  }


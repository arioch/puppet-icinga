# == Class: icinga::plugins::checkipmichassis
#
# This class provides a checkhipmichassis plugin.
#
class icinga::plugins::checkipmichassis (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
) inherits icinga {

   package { 'perl-Nagios-Plugin':
    ensure => 'installed'
   }
    
   file { "${::icinga::plugindir}/check_ipmitool.pl":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source => 'puppet:///modules/icinga/check_ipmitool.pl',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }
    file { "${::icinga::includedir_client}/ipmi_chassis.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/ipmi_chassis.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }



    @@nagios_service { "ipmi_chassis_status${::fqdn}":
      check_command         => 'check_nrpe_command!check_ipmi_chassis',
      service_description   => 'IPMI chassis status',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    sudo::conf{'ipmi_chassis_conf':
    content => "Defaults:nagios !requiretty
    nagios ALL=(ALL) NOPASSWD:/usr/bin/ipmitool\n",
    }

  }


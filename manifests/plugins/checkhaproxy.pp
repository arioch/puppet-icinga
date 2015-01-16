# == Class: icinga::plugins::checkhaproxy
#
# This class provides a checkhaproxy plugin.
#
class icinga::plugins::checkhaproxy (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
  $username                     = hiera('haproxy_username', 'haproxy'),
  $password                     = hiera('haproxy_pass', 'V3ry_Str0ng_P4ssword'),

) inherits icinga {


    file { "${::icinga::plugindir}/check_haproxy.rb":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source => 'puppet:///modules/icinga/check_haproxy.rb',
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }
    file { "${::icinga::includedir_client}/haproxy.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/haproxy.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }



    @@nagios_service { "check_haproxy_${::fqdn}":
      check_command         => 'check_nrpe_command!check_haproxy',
      service_description   => 'HAproxy backends',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

  }


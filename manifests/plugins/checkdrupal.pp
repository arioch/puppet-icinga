# == Class: icinga::plugins::checkdrupal
#
# This class provides a checkdrupal plugin.
#
class icinga::plugins::checkdrupal (
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
  $key                   = '',
  $path                  = 'nagios'
) inherits icinga {
  if $icinga::client {
    file { "${::icinga::plugindir}/check_drupal":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      seltype => 'nagios_unconfined_plugin_exec_t',
      content => template ('icinga/plugins/check_drupal.erb'),
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file{"${::icinga::includedir_client}/drupal.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_drupal]=${::icinga::plugindir}/check_drupal -U ${key} -H ${::hostname} -P ${path}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_drupal_${::hostname}":
      use                   => 'generic-service',
      check_command         => 'check_nrpe_command!check_drupal',
      service_description   => 'Drupal status',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}

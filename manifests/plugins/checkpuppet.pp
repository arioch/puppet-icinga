# == Class: icinga::plugins::checkpuppet
#
# This class provides a checkpuppet plugin.
#
class icinga::plugins::checkpuppet (
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    file { "${::icinga::plugindir}/check_puppet":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      seltype => 'nagios_admin_plugin_exec_t',
      content => template ('icinga/plugins/check_puppet.rb.erb'),
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file{"${::icinga::includedir_client}/puppet.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_puppet]=${::icinga::plugindir}/check_puppet -w 604800 -c 907200\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_puppet_${::fqdn}":
      check_command         => 'check_nrpe_command!check_puppet',
      service_description   => 'Puppet',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

# == Class: icinga::plugins::checknginx
#
# This class provides a checknginx plugin.
#
class icinga::plugins::checknginx (
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  if $icinga::client {
    file { "${::icinga::plugindir}/check_nginx":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      seltype => 'nagios_admin_plugin_exec_t',
      content => template ('icinga/plugins/check_nginx'),
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file{"${::icinga::includedir_client}/nginx.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_nginx]=${::icinga::plugindir}/check_nginx -U 10.0.192.1:80 -P /bootstrap -w 300 -c 500\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_nginx_${::fqdn}":
      check_command         => 'check_nrpe_command!check_nginx',
      service_description   => 'Nginx',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}


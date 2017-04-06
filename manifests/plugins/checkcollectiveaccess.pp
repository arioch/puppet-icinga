# == Class: icinga::plugins::checkcollectiveaccess
class icinga::plugins::checkcollectiveaccess (
  $host,
  $user,
  $password,
  $configuration,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits ::icinga {



  file{"${::icinga::includedir_client}/collectiveaccess.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_collectiveaccess]=${::icinga::usrlib}/nagios/plugins/check_collective-access.rb -h ${host} -u ${user} -p ${password} -c ${::icinga::includedir_client}/ca_config.yaml\n",
    notify  => Service[$::icinga::service_client],
  }

  file {"${::icinga::includedir_client}/ca_config.yaml":
    content => inline_template('<%= @configuration.to_yaml %>'),
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service{"check_collectiveaccess_${::fqdn}":
    check_command         => 'check_nrpe_command!check_collectiveaccess',
    service_description   => 'CollectiveAccess',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

# == Class: icinga::plugins::checktopologylatency
class icinga::plugins::checktopologylatency (
  $host                  = 'localhost',
  $port                  = 8888,
  $critical_latency      = 1200,
  $warning_latency       = 1000,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits ::icinga {

  package {'nagios-plugins-topology-latency':
    ensure => present,
  }

  file{"${::icinga::includedir_client}/topology_latency.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_storm_latency]=${::icinga::usrlib}/nagios/plugins/check_topology-latency.rb -h ${host} -p ${port} -w ${warning_latency} -c ${critical_latency}\n",
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service{"check_collectiveaccess_${::fqdn}":
    check_command         => 'check_nrpe_command!check_storm_latency',
    service_description   => 'Storm Topology Latency',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}


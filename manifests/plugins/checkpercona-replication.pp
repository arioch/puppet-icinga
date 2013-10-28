# == Class: icinga::plugins::percona
#
# This class provides the percona plugin.
#
# http://www.percona.com/doc/percona-monitoring-plugins/nagios/
#
class icinga::plugins::checkpercona-replication (
  $ensure                = present,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
  $contact_groups        = $::environment,
  $warning               = '1',
  $critical              = '1',
  $socket                = '/var/lib/mysql/mysql.sock',
  $defaults_file         = '/etc/my.cnf',

) inherits icinga {

  $pkg_percona_nagios = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => 'percona-nagios-plugins',
    /Debian|Ubuntu/                       => 'percona-nagios-plugins',
  }

  if ! defined(Package[$pkg_percona_nagios]) {
    package {
      $pkg_percona_nagios:
        ensure => $ensure,
        notify => Service[$icinga::service_client];
    }
  }

  Nagios_service {
    host_name             => $::fqdn,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    contact_groups        => $contact_groups,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

  file{"${::icinga::includedir_client}/check_percona_replication_running.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_percona_replication_running]=sudo ${::icinga::plugindir}/pmp-check-mysql-replication-running -w ${warning} -c ${critical}\n",
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service { "check_percona_replication_running${::fqdn}":
    check_command       => 'check_nrpe_command!check_percona_replication_running',
    service_description => 'Percona: Replication Running',
  }

}
# == Class: icinga::plugins::check_pgactivity
class icinga::plugins::check_pgactivity (
  $pgsqlpassword,
  $ensure                = present,
  $contact_groups        = $::environment,
  $host                  = 'localhost',
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  package {'perl-Data-Dumper':
    ensure =>  present,
  }

  package { 'nagios-plugins-pgactivity':
    ensure => installed,
  }

  file { "${::icinga::includedir_client}/pgactivity.cfg":
    content => "command[check_pgactivity]=/usr/lib64/nagios/plugins/check_pgactivity -h ${host} -s connection",
  #   notify  => Service[$::icinga::service_client];
  }

  file { '/var/spool/nagios/.pgpass':
    ensure  => file,
    mode    => '0600',
    owner   => 'nagios',
    group   => 'nagios',
    content => "#manged by puppet\n${host}:5432:*:postgres:${pgsqlpassword}",
  }

  @@nagios_service { "check_pgactivity_${::fqdn}":
    check_command         => 'check_nrpe_command!check_pgactivity',
    service_description   => 'PostgreSQL Status',
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    max_check_attempts    => $max_check_attempts,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

# == Class: icinga::checkprocstat
#
# This class provides a checkprocstat plugin.
#
class icinga::plugins::checkprocstat (
  $ensure                = present,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  $package_name = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => 'nagios-plugins-linux-procstat',
    /Debian|Ubuntu/                       => 'nagios-plugin-check-linux-procstat',
  }

  package { $package_name:
    ensure => $ensure,
  }

  file {
    "${::icinga::includedir_client}/checkprocstat.cfg":
      ensure  => $ensure,
      notify  => Service[$icinga::service_client],
      content => template('icinga/plugins/checkprocstat.cfg.erb');
  }

  @@nagios_service { "check_procstat_${::fqdn}":
    check_command         => 'check_nrpe_command!check_procstat',
    host_name             => $::fqdn,
    max_check_attempts    => $max_check_attempts,
    contact_groups        => $contact_groups,
    service_description   => 'procstat',
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    action_url            => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }
}


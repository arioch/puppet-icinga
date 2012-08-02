class icinga::plugins::checkprocstat (
  $ensure             = present,
  $max_check_attempts = '4'
) inherits icinga {

  $package_name = $::operatingsystem ? {
    /CentOS|RedHat/ => 'nagios-plugins-linux-procstat',
    /Debian|Ubuntu/ => 'nagios-plugin-check-linux-procstat',
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

  @@nagios_service { "check_procstat_${::hostname}":
    check_command       => 'check_nrpe_command!check_procstat',
    host_name           => $::fqdn,
    max_check_attempts  => $max_check_attempts,
    service_description => 'procstat',
    action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }
}


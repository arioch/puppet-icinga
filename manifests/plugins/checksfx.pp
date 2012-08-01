class icinga::plugins::checksfx (
  $ensure             = present,
  $perfdata           = false,
  $max_check_attempts = '4'
) {

  $pkg_perl_mysql_connecter = $::operatingsystem ? {
    /CentOS|RedHat/ => 'perl-DBD-MySQL',
    /Debian|Ubuntu/ => 'libdbd-mysql-perl',
  }

  $pkg_perl_libwww_perl = $::operatingsystem ? {
    /CentOS|RedHat/ => 'perl-libwww-perl',
    /Debian|Ubuntu/ => 'libwww-perl',
  }

  $pkg_nagios_plugins_mysqld = $::operatingsystem ? {
    /CentOS|RedHat/ => 'nagios-plugins-mysqld',
    /Debian|Ubuntu/ => 'nagios-plugin-check-mysqld',
  }

  $pkg_nagios_plugins_httpd = $::operatingsystem ? {
    /CentOS|RedHat/ => 'nagios-plugins-apache-auto',
    /Debian|Ubuntu/ => 'nagios-plugin-check-apache-auto',
  }

  package {
    $pkg_perl_mysql_connecter:
      ensure => $ensure;

    $pkg_perl_libwww_perl:
      ensure => $ensure;

    $pkg_nagios_plugins_mysqld:
      ensure => $ensure,
      notify => Service[$icinga::service_client];

    $pkg_nagios_plugins_httpd:
      ensure => $ensure,
      notify => Service[$icinga::service_client];
  }

  if $perfdata {
    file {
      "${::icinga::includedir_client}/sfx_mysqld_performance.cfg":
        ensure  => $ensure,
        notify  => Service[$icinga::service_client],
        content => template('icinga/plugins/sfx_mysqld_performance.cfg.erb');

      "${::icinga::includedir_client}/sfx_httpd_performance.cfg":
        ensure  => $ensure,
        notify  => Service[$icinga::service_client],
        content => template('icinga/plugins/sfx_httpd_performance.cfg.erb');
    }

    Nagios_service {
      host_name          => $::fqdn,
      max_check_attempts => $max_check_attempts,
      action_url         => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
      target             => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_sfx_httpd_perf_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_httpd_performance',
      service_description => 'check_sfx_httpd_perf',
    }

    @@nagios_service { "check_sfx_mysqld_perf_1_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_1',
      service_description => 'check_sfx_mysqld_perf_1',
    }

    @@nagios_service { "check_sfx_mysqld_perf_2_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_2',
      service_description => 'check_sfx_mysqld_perf_2',
    }

    @@nagios_service { "check_sfx_mysqld_perf_3_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_3',
      service_description => 'check_sfx_mysqld_perf_3',
    }

    @@nagios_service { "check_sfx_mysqld_perf_4_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_4',
      service_description => 'check_sfx_mysqld_perf_4',
    }

    @@nagios_service { "check_sfx_mysqld_perf_5_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_5',
      service_description => 'check_sfx_mysqld_perf_5',
    }

    @@nagios_service { "check_sfx_mysqld_perf_6_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_6',
      service_description => 'check_sfx_mysqld_perf_6',
    }

    @@nagios_service { "check_sfx_mysqld_perf_7_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_7',
      service_description => 'check_sfx_mysqld_perf_7',
    }

    @@nagios_service { "check_sfx_mysqld_perf_8_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_8',
      service_description => 'check_sfx_mysqld_perf_8',
    }

    @@nagios_service { "check_sfx_mysqld_perf_9_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_9',
      service_description => 'check_sfx_mysqld_perf_9',
    }

    @@nagios_service { "check_sfx_mysqld_perf_10_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_10',
      service_description => 'check_sfx_mysqld_perf_10',
    }

    @@nagios_service { "check_sfx_mysqld_perf_11_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_11',
      service_description => 'check_sfx_mysqld_perf_11',
    }

    @@nagios_service { "check_sfx_mysqld_perf_12_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_12',
      service_description => 'check_sfx_mysqld_perf_12',
    }

    @@nagios_service { "check_sfx_mysqld_perf_13_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_13',
      service_description => 'check_sfx_mysqld_perf_13',
    }

    @@nagios_service { "check_sfx_mysqld_perf_14_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_14',
      service_description => 'check_sfx_mysqld_perf_14',
    }

    @@nagios_service { "check_sfx_mysqld_perf_15_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_15',
      service_description => 'check_sfx_mysqld_perf_15',
    }

    @@nagios_service { "check_sfx_mysqld_perf_16_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_16',
      service_description => 'check_sfx_mysqld_perf_16',
    }

    @@nagios_service { "check_sfx_mysqld_perf_17_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_17',
      service_description => 'check_sfx_mysqld_perf_17',
    }

    @@nagios_service { "check_sfx_mysqld_perf_18_${::hostname}":
      check_command       => 'check_nrpe_command!check_sfx_mysqld_performance_18',
      service_description => 'check_sfx_mysqld_perf_18',
    }
  }
}


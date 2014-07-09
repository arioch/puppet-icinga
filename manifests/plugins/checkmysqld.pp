# == Class: icinga::plugins::checkmysqld
#
# This class provides a checkmysqld plugin.
#
class icinga::plugins::checkmysqld (
  $ensure                = present,
  $perfdata              = true,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  $pkg_nagios_plugins_mysqld = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => 'nagios-plugins-mysqld',
    /Debian|Ubuntu/                       => 'nagios-plugin-check-mysqld',
  }

  $pkg_perl_mysql_connecter = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => 'perl-DBD-MySQL',
    /Debian|Ubuntu/                       => 'libdbd-mysql-perl',
  }

  package {
    $pkg_perl_mysql_connecter:
      ensure => $ensure;

    $pkg_nagios_plugins_mysqld:
      ensure => $ensure,
      notify => Service[$icinga::service_client];
  }

  file { "${::icinga::includedir_client}/mysqld.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    notify  => Service[$::icinga::service_client],
    content => "command[check_mysqld]=${::icinga::plugindir}/check_mysqld.pl",
  }

  @@nagios_service { "check_mysqld_performance_${::fqdn}":
    check_command       => 'check_nrpe_command!check_mysqld',
    service_description => 'mysqld',
    host_name           => $::fqdn,
    max_check_attempts  => $max_check_attempts,
    target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
  }

  if $perfdata {
    file {
      "${::icinga::includedir_client}/mysqld_performance.cfg":
        ensure  => $ensure,
        notify  => Service[$icinga::service_client],
        content => template('icinga/plugins/mysqld_performance.cfg.erb');
    }

    Nagios_service {
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

    @@nagios_service { "check_mysqld_performance_1_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_1',
      service_description => 'mysqld perf 1',
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    }

    @@nagios_service { "check_mysqld_performance_2_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_2',
      service_description => 'mysqld perf 2',
    }

    @@nagios_service { "check_mysqld_performance_3_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_3',
      service_description => 'mysqld perf 3',
    }

    @@nagios_service { "check_mysqld_performance_4_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_4',
      service_description => 'mysqld perf 4',
    }

    @@nagios_service { "check_mysqld_performance_5_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_5',
      service_description => 'mysqld perf 5',
    }

    @@nagios_service { "check_mysqld_performance_6_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_6',
      service_description => 'mysqld perf 6',
    }

    @@nagios_service { "check_mysqld_performance_7_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_7',
      service_description => 'mysqld perf 7',
    }

    @@nagios_service { "check_mysqld_performance_8_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_8',
      service_description => 'mysqld perf 8',
    }

    @@nagios_service { "check_mysqld_performance_9_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_9',
      service_description => 'mysqld perf 9',
    }

    @@nagios_service { "check_mysqld_performance_10_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_10',
      service_description => 'mysqld perf 10',
    }

    @@nagios_service { "check_mysqld_performance_11_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_11',
      service_description => 'mysqld perf 11',
    }

    @@nagios_service { "check_mysqld_performance_12_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_12',
      service_description => 'mysqld perf 12',
    }

    @@nagios_service { "check_mysqld_performance_13_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_13',
      service_description => 'mysqld perf 13',
    }

    @@nagios_service { "check_mysqld_performance_14_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_14',
      service_description => 'mysqld perf 14',
    }

    @@nagios_service { "check_mysqld_performance_15_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_15',
      service_description => 'mysqld perf 15',
    }

    @@nagios_service { "check_mysqld_performance_16_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_16',
      service_description => 'mysqld perf 16',
    }

    @@nagios_service { "check_mysqld_performance_17_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_17',
      service_description => 'mysqld perf 17',
    }

    @@nagios_service { "check_mysqld_performance_18_${::fqdn}":
      check_command       => 'check_nrpe_command!check_mysqld_performance_18',
      service_description => 'mysqld perf 18',
    }
  }
}


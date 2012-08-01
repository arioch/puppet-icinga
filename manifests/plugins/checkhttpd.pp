class icinga::plugins::checkhttpd (
  $ensure             = present,
  $perfdata           = false,
  $max_check_attempts = '4'
) {

  $pkg_perl_libwww_perl = $::operatingsystem ? {
    /CentOS|RedHat/ => 'perl-libwww-perl',
    /Debian|Ubuntu/ => 'libwww-perl',
  }

  $pkg_nagios_plugins_httpd = $::operatingsystem ? {
    /CentOS|RedHat/ => 'nagios-plugins-apache-auto',
    /Debian|Ubuntu/ => 'nagios-plugin-check-apache-auto',
  }

  package {
    $pkg_perl_libwww_perl:
      ensure => $ensure;

    $pkg_nagios_plugins_httpd:
      ensure => $ensure,
      notify => Service[$icinga::service_client];
  }

  if $perfdata {
    file {
      "${::icinga::includedir_client}/httpd_performance.cfg":
        ensure  => $ensure,
        notify  => Service[$icinga::service_client],
        content => template('icinga/plugins/httpd_performance.cfg');
    }

    @@nagios_service { "check_httpd_perf_${::hostname}":
      check_command       => 'check_nrpe_command!check_httpd_performance',
      host_name           => $::fqdn,
      max_check_attempts  => $max_check_attempts,
      service_description => 'check_httpd_perf',
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}


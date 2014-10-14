# == Class: icinga::plugins::checkhttpd
#
# This class provides a checkhttpd plugin.
#
class icinga::plugins::checkhttpd (
  $ensure                = present,
  $perfdata              = false,
  $perfargs              = '',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  $pkg_perl_libwww_perl = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => 'perl-libwww-perl',
    /Debian|Ubuntu/                       => 'libwww-perl',
  }

  $pkg_nagios_plugins_httpd = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => 'nagios-plugins-apache-auto',
    /Debian|Ubuntu/                       => 'nagios-plugin-check-apache-auto',
  }

  package {
    $pkg_perl_libwww_perl:
      ensure => $ensure;

    $pkg_nagios_plugins_httpd:
      ensure => $ensure,
      notify => Service[$icinga::service_client];
  }

  file{"${::icinga::plugindir}/check_apache-auto.pl":
    seltype => 'nagios_services_plugin_exec_t',
    require => Package[$pkg_nagios_plugins_httpd],
  }

  if $perfdata {
    file {
      "${::icinga::includedir_client}/httpd_performance.cfg":
        ensure  => $ensure,
        owner   => $::icinga::client_user,
        group   => $::icinga::client_group,
        notify  => Service[$icinga::service_client],
        content => template('icinga/plugins/httpd_performance.cfg');
    }

    @@nagios_service { "check_httpd_perf_${::fqdn}":
      check_command         => 'check_nrpe_command!check_httpd_performance',
      host_name             => $::fqdn,
      max_check_attempts    => $max_check_attempts,
      contact_groups        => $contact_groups,
      service_description   => 'Apache',
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      action_url            => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}


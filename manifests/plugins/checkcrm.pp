# == Class: icinga::plugins::checkcrm
#
# This class provides a check_crm plugin.
#
# Checks pacemaker
#
# Source:  http://exchange.nagios.org/directory/Plugins/Clustering-and-High-2DAvailability/Check-CRM/details
#
class icinga::plugins::checkcrm (
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $contact_groups         = $::environment,
) {

  require icinga

  if $icinga::client {

    $pkg_nagios_plugin_checkcrm = $::operatingsystem ? {
      /CentOS|RedHat/ => 'nagios-plugins-checkcrm',
      default         => fail('Operating system not supported'),
    }

    $pkg_perl_nagios_plugin = $::operatingsystem ? {
      /CentOS|RedHat/ => 'perl-Nagios-Plugin',
      default         => fail('Operating system not supported'),
    }

    package { $pkg_nagios_plugin_checkcrm:
      ensure => installed,
    }

    package { $pkg_perl_nagios_plugin:
      ensure => installed,
    }


    file{"${::icinga::includedir_client}/check_crm_${host_name}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_crm_${host_name}]=${::icinga::plugindir}/check_crm\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_crm_${host_name}":
      check_command         => "check_nrpe_command!check_crm_${host_name}",
      service_description   => 'Pacemaker',
      host_name             => $host_name,
      use                   => 'generic-service',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}
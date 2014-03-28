# == Class: icinga::plugins::checkedc
#
# This class provides a checkedc plugin.
#
class icinga::plugins::checkedc (
  $daemon_name           = 'dummy',
  $ensure                = 'present',
  $check_warning         = '2:',
  $check_critical        = '1:10',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  $package_name = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => 'nagios-plugins-procs',
    /Debian|Ubuntu/                       => 'nagios-plugins-basic',
  }

  package { $package_name:
    ensure => $ensure,
  }

  file{ "${::icinga::includedir_client}/${daemon_name}.cfg" :
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_$daemon_name]=${::icinga::plugindir}/check_procs -w $check_warning -c $check_critical -a $daemon_name\n",
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service{"check_procs_$daemon_name":
    ensure                => $ensure,
    check_command         => "check_nrpe_command!check_$daemon_name",
    service_description   => "Check $daemon_name processes",
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

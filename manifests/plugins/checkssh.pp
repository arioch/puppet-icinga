# == Class: icinga::plugins::checkssh
#
# This class provides a checkssh plugin.
#
class icinga::plugins::checkssh (
  $sshport        = '22',
  $check_warning  = '',
  $check_critical = ''
) inherits icinga {
  if $icinga::client {
    @@nagios_service { "check_ssh_${::hostname}":
      check_command       => "check_ssh!-p ${sshport}",
      service_description => 'SSH',
      host_name           => $::fqdn,
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}


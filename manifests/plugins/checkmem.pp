# == Class: icinga::plugins::checkmem
#
# This class provides a checkmem plugin.
#
class icinga::plugins::checkmem (
  $max_check_attempts = $::icinga::max_check_attempts
) inherits icinga {
  if $icinga::client {

    package{'nagios-plugins-checkmem':
      ensure => 'present',
    }

    @@nagios_service{"check_mem_${::hostname}":
      check_command       => 'check_nrpe_command!check_mem',
      service_description => 'RAM',
      host_name           => $::fqdn,
      max_check_attempts  => $max_check_attempts,
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}

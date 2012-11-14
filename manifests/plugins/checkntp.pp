class icinga::plugins::checkntp (
  ntp_server         = 'pool.ntp.org',
  warn_value         = '1',
  crit_value         = '10',
  max_check_attempts = $::icinga::max_check_attempts,
) inherits ::icinga {

  require ::ntp

  file{"${::icinga::includedir_client}/ntp.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_ntp]=${::icinga::usrlib}/nagios/plugins/check_ntp -H ${ntp_server} -w ${warn_value} -c ${crit_value}\n",
  }

  @@nagios_service{"check_ntp_${::fqdn}":
    check_command       => 'check_nrpe!check_ntp',
    service_description => 'NTP Time Drift'
    host_name           => $::fqdn,
    max_check_attempts  => $max_check_attempts,
    target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

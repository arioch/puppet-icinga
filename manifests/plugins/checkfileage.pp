# == Class: icinga::plugins::checkfileage
define icinga::plugins::checkfileage (
  $critical,
  $warning,
  $file,
  $datetype              = 'M',
  $not_found_exit_code   = 3,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) {

  require ::icinga
  $_file = inline_template("<%= @file.gsub('/','_') %>")
  file{"${::icinga::includedir_client}/check_file_age${_file}.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_file_age${_file}]=${::icinga::usrlib}/nagios/plugins/check_fileage.py -w ${warning} -c ${critical} -f ${file} -d ${datetype} -n ${not_found_exit_code}",
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service{"check_fileage${_file}_${::fqdn}":
    check_command         => "check_nrpe_command!check_file_age${_file}",
    service_description   => "Check File Age ${file}",
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

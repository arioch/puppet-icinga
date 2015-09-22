# == Class: icinga::plugins::checkmysqld
#
# This class provides a checkmysqld plugin.
#
class icinga::plugins::checkmysqlclient (
  $db_name,
  $db_host,
  $db_user,
  $db_pass,
  $ensure                = present,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) inherits icinga {

  file { "${::icinga::includedir_client}/mysql_client_${db_name}.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    notify  => Service[$::icinga::service_client],
    content => "command[check_mysql_${db_name}]=/usr/lib64/nagios/plugins/check_mysql -H ${db_host} -u ${db_user} -p ${db_pass} -d ${db_name}"
  }

  @@nagios_service { "check_mysql_client_${::fqdn}_${db_name}":
    check_command       => "check_nrpe_command!check_mysql_${db_name}",
    service_description => "mysql client db: ${db_name}",
  }

}


# == Class: icinga::plugins::checkmysqlclient
#
define icinga::plugins::checkmysqlclient (
  $database,
  $host,
  $user,
  $password              = undef,
  $hash                  = undef,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) {

  require icinga

  if $password {
    file { "${::icinga::includedir_client}/mysql_client_${database}-${user}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      notify  => Service[$::icinga::service_client],
      content => "command[check_mysql_${database}_${user}]=/usr/lib64/nagios/plugins/check_mysql -H ${host} -u ${user} -p ${password} -d ${database}"
    }

    @@nagios_service { "check_mysql_client_${::fqdn}_${database}_${user}":
      check_command         => "check_nrpe_command!check_mysql_${database}_${user}",
      service_description   => "mysql client db: ${database} user: ${user}",
      contact_groups        => $contact_groups,
      host_name             => $::fqdn,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}


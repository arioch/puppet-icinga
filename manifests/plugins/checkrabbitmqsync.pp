# == Class: icinga::plugins::checkrabbitmqsync
define icinga::plugins::checkrabbitmqsync (
  $user,
  $password,
  $vhost                 = $name,
  $host                  = 'localhost',
  $port                  = '15672',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) {

  require icinga

  file{"${::icinga::includedir_client}/check_rabbit_sync_${vhost}.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_rabbit_sync_${vhost}]=${::icinga::usrlib}/nagios/plugins/check_rabbitmq-sync.rb -h ${host} -u ${user} -p ${password} -P ${port} -v ${vhost}\n",
    notify  => Service[$::icinga::service_client],
  }

  @@nagios_service{"check_rabbit_sync_${vhost}_${::fqdn}":
    check_command         => "check_nrpe_command!check_rabbit_sync_${vhost}",
    service_description   => "RabbitMQ node sync vhost: ${vhost}",
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}

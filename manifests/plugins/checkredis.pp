# == Class: icinga::plugins::checkredis
#
# This class provides a checkredis plugin.
#
define icinga::plugins::checkredis (
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $contact_groups         = $::environment,
  $bind_address           = 'localhost',
  $port                   = '6379',
) {

  require icinga

  if $icinga::client {

    $pkg = $::operatingsystem ? {
      'centos' => 'perl-Redis',
      'debian' => 'libredis-perl',
    }

    if (!defined(Package[$pkg])) {
      package { $pkg: }
    }

    file { "${::icinga::plugindir}/check_redis":
      ensure  => 'file',
      mode    => '0755',
      content => template('icinga/plugins/check_redis'),
    }

    file{"${::icinga::includedir_client}/check_redis_${title}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_redis]=${::icinga::plugindir}/check_redis -H ${bind_address} -p ${port}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_redis_${host_name}_${title}":
      check_command         => 'check_nrpe_command!check_redis',
      service_description   => 'Redis',
      host_name             => $host_name,
      use                   => 'generic-service',
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}

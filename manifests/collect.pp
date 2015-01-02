# == Class: icinga::collect
#
# This class provides resource collection.
#
class icinga::collect {

  if $::icinga::server and $::icinga::collect_resources {
    # Set defaults for collected resources.
    Nagios_host <<| |>>              {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_service <<| |>>           {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_hostextinfo <<| |>>       {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_command <<| |>>           {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_contact <<| |>>           {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_contactgroup <<| |>>      {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_hostdependency <<| |>>    {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_hostescalation <<| |>>    {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_hostgroup <<| |>>         {
      notify => Service[$::icinga::service_server],
      target => "${::icinga::targetdir}/hostgroups.cfg",
    }
    Nagios_servicedependency <<| |>> {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_serviceescalation <<| |>> {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_serviceextinfo <<| |>>    {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_servicegroup <<| |>>      {
      notify => Service[$::icinga::service_server],
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Nagios_timeperiod <<| |>>        {
      notify => Service[$::icinga::service_server],
      target => "${::icinga::targetdir}/timeperiods.cfg",
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
    Icinga::Downtime <<| |>>         {
      owner  => $::icinga::server_user,
      group  => $::icinga::server_group,
    }
  }

  if $::icinga::client and $::icinga::export_resources {
    @@nagios_host{$::icinga::collect_hostname:
      ensure                => present,
      address               => $::icinga::collect_ipaddress,
      max_check_attempts    => $::icinga::max_check_attempts,
      check_command         => 'check-host-alive',
      use                   => 'linux-server',
      parents               => $::icinga::parents,
      hostgroups            => $::icinga::hostgroups,
      action_url            => '/pnp4nagios/graph?host=$HOSTNAME$',
      notification_period   => $::icinga::notification_period,
      notifications_enabled => $::icinga::notifications_enabled,
      icon_image_alt        => $::operatingsystem,
      icon_image            => "os/${::operatingsystem}.png",
      statusmap_image       => "os/${::operatingsystem}.png",
      target                => "${::icinga::targetdir}/hosts/host-${::fqdn}.cfg",
    }
  }
}

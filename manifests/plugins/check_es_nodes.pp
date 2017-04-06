# == Class: icinga::plugins::check_es_nodes
class icinga::plugins::check_es_nodes (
  $ensure                       = present,
  $expected_nodes_in_cluster    = 1,
  $contact_groups               = $::environment,
  $host                         = 'localhost',
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,

) inherits icinga {
  file{"${::icinga::includedir_client}/check_es_nodes.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => "command[check_es_nodes]=${::icinga::plugindir}/check_es-nodes.py --host=${host} --expected_nodes_in_cluster=${expected_nodes_in_cluster}",
    notify  => Service[$::icinga::service_client],
  }

  package { 'nagios-plugins-es-nodes':
    ensure => 'present',
  }

  ## Exported config to be included in the Icinga/Nagios host

  @@nagios_service{"check_es_nodes_${::fqdn}":
    check_command         => 'check_nrpe_command!check_es_nodes',
    service_description   => "Check ElasticSearch Nodes${::fqdn}",
    host_name             => $::fqdn,
    contact_groups        => $::environment,
    use                   => 'generic-service',
    notification_period   => $::icinga::notification_period,
    notifications_enabled => $::icinga::notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }
}

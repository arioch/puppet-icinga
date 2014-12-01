# == Class: icinga::plugins::checkelasticsearch
#
# This class provides a checkelasticsearch plugin.
#
class icinga::plugins::checkelasticsearch (
  $pkgname               = 'nagios-plugin-elasticsearch',
) {

  if $icinga::client {
    if !defined(Package['python-pip']){
      package{'python-pip':
        ensure => present,
      }
    }

    if !defined(Package[$pkgname]) {
      package{$pkgname:
        ensure   => present,
        provider => 'pip',
        require  => Package['python-pip'],
      }
    }

    file { "${::icinga::includedir_client}/elasticsearch.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => 'command[check_elasticsearch]=/usr/bin/check_elasticsearch',
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_elasticsearch_status_${::fqdn}":
      check_command         => 'check_nrpe_command!check_elasticsearch',
      service_description   => 'Elasticsearch status',
      host_name             => $::fqdn,
      contact_groups        => $::environment,
      use                   => 'generic-service',
      notification_period   => $::icinga::notification_period,
      notifications_enabled => $::icinga::notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}

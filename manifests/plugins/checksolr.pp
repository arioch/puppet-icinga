# == Class: icinga::plugins::checksolr
#
# This class provides a check solr plugin.
#
class icinga::plugins::checksolr (
  $max_check_attempts = '4'
) inherits icinga {
  if $icinga::client {
    file { "${::icinga::plugindir}/check_solr":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template ('icinga/plugins/check_solr.erb'),
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file { "${::icinga::plugindir}/check_solr_rows":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template ('icinga/plugins/check_solr_rows.erb'),
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file{"${::icinga::includedir_client}/solr.cfg":
      ensure  => 'file',
      mode    => '0664',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_solr]=${::icinga::usrlib}/nagios/plugins/check_solr\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_solr_${::hostname}":
      use                 => 'generic-service',
      check_command       => 'check_nrpe_command!check_solr',
      service_description => 'Solr status',
      host_name           => $::fqdn,
      max_check_attempts  => $max_check_attempts,
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}

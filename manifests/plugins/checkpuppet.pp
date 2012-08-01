class icinga::plugins::checkpuppet (
  $max_check_attempts = '4'
) {
  if $icinga::client {
    file { "${::icinga::plugindir}/check_puppet":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template ('icinga/plugins/check_puppet.rb.erb'),
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    @@nagios_service { "check_puppet_${::hostname}":
      check_command       => 'check_nrpe_command!check_puppet',
      service_description => 'Puppet',
      host_name           => $::fqdn,
      max_check_attempts  => $max_check_attempts,
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}

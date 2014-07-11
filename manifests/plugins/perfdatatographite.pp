# Class: icinga::plugins::perfdatatographite
#
class icinga::plugins::perfdatatographite (
  $carbon_host = undef,
  $carbon_port = undef,
){

  require ::icinga

  if $::icinga::server {
    file{ '/usr/local/bin/transform_perfdata.sh':
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('icinga/plugins/transform_perfdata.sh.erb'),
      notify  => Service[$::icinga::service_server],
      require => Class['::icinga::config'],
    }

    file { '/usr/local/bin/transform_perfdata.awk':
      ensure  => file,
      mode    => '0644',
      owner   => 'icinga',
      group   => 'icinga',
      content => template('icinga/plugins/transform_perfdata.awk.erb'),
    }

    @@nagios_command{'process-service-perfdata-to-graphite-file':
      ensure       => present,
      command_line => "${::icinga::plugindir}/transform_perfdata.sh",
    }
  }
}

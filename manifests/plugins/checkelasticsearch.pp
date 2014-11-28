# == Class: icinga::plugins::checkelasticsearch
#
# This class provides a checkelasticsearch plugin.
#
class icinga::plugins::checkelasticsearch (
  $pkgname               = 'nagios-plugin-elasticsearch',
) {

  require icinga

  if !defined(Package['python-pip']){
    package{'python-pip':
      ensure => present,
    }
  }

  if $icinga::server {
    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure   => present,
        provider => 'pip',
        require  => Package['python-pip'],
      }
    }

    nagios_command{'check_elasticsearch':
      ensure       => present,
      command_line => '$USER1$/check_elasticsearch -H $ARG1$ -p $ARG2$',
      target       => "${::icinga::targetdir}/commands/check_elasticsearch.cfg",
    }
  }
}

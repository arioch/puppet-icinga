# Class: icinga::plugins::icingaweb::config
#
# This class will configure the icinga-web instance
class icinga::plugins::icingaweb::config {
  File {
    owner   => $icinga::params::webserver_user,
    group   => $icinga::params::webserver_group,
    require => Package[$icinga::params::icingaweb_pkg],
    notify  => [
      Service[$icinga::params::service_server],
      Service[$icinga::params::service_webserver],
    ]
  }

  file {
    $icinga::params::icingaweb_logdir:
      ensure => directory;

    '/etc/icinga-web/conf.d/databases.xml':
      ensure   => present,
      content  => template('icinga/plugins/icingaweb/databases.xml');
  }
}

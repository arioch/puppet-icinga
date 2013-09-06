# Class: icinga::plugins::icingaweb::config
#
# This class will configure the icinga-web instance
class icinga::plugins::icingaweb::config {
  File {
    owner   => $icinga::params::webserver_user,
    group   => $icinga::params::webserver_group,
    require => Package[$icinga::params::icingaweb_pkg],
  }

  file {
    $icinga::params::icingaweb_confdir:
      ensure  => directory;

    $icinga::params::icingaweb_logdir:
      ensure => directory;

    "${icinga::params::icingaweb_confdir}/etc/schema/mysql.sql":
      ensure   => present,
      notify   => Exec['icinga_web-db-initialize'];

    '/etc/icinga-web/conf.d/databases.xml':
      ensure  => present,
      owner   => 'root',
      mode    => '0640',
      content => template('icinga/plugins/icingaweb/databases.xml');
  }

  exec {
    'icinga_web-db-initialize':
      unless  => "mysqlshow ${icinga::params::icingaweb_dbname} | grep cronk",
      command => "mysql -u root icinga_web < ${icinga::params::icingaweb_confdir}/etc/schema/mysql.sql";
  }
}

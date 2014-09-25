# == Class: icinga::plugins::idoutils::config
#
# This class provides the idoutils plugin's configuration.
#
class icinga::plugins::idoutils::config {
  # mysqldb { $icinga::idoutils_dbname:
  #   user     => $icinga::idoutils_dbuser,
  #   password => $icinga::idoutils_dbpass,
  # }

  File {
    owner   => $icinga::server_user,
    group   => $icinga::server_group,
    require => Package[$icinga::idoutils_pkg],
    notify  => Service[$icinga::service_server],
  }

  file {
    $icinga::idoutils_confdir:
      ensure => directory;

    "${::icinga::idoutils_confdir}/mysql":
      ensure => directory;

    "${::icinga::confdir_server}/ido2db.cfg":
      ensure  => present,
      content => template('icinga/plugins/idoutils/ido2db.cfg.erb');

    "${::icinga::confdir_server}/idomod.cfg":
      content => template('icinga/plugins/idoutils/idomod.cfg');

    "${::icinga::idoutils_confdir}/mysql/icinga-web-priv.sql":
      content => template('icinga/plugins/idoutils/icinga-web-priv.sql.erb'),
      require => Mysqldb[$icinga::idoutils_dbname];
  }

  Exec {
    require => [
      Package[$icinga::idoutils_pkg],
      File["${::icinga::idoutils_confdir}/mysql/icinga-web-priv.sql"]
    ],
  }

  exec {
    'icinga-db-priv':
      command => "/usr/bin/mysql -u ${::icinga::idoutils_dbuser} --password=${::icinga::idoutils_dbpass} ${::icinga::idoutils_dbname} < ${::icinga::idoutils_confdir}/mysql/icinga-web-priv.sql",
      unless  => "/usr/bin/mysql -e \"select * from information_schema.user_privileges\" | grep ${::icinga::idoutils_dbname}";
    'icinga-db-tables':
      command => "/usr/bin/mysql -u ${::icinga::idoutils_dbuser} --password=${::icinga::idoutils_dbpass} ${::icinga::idoutils_dbname} < ${::icinga::idoutils_confdir}/mysql/mysql.sql",
      unless  => "/usr/bin/mysqlshow ${::icinga::idoutils_dbname} | grep icinga_contacts",
  }
}

class icinga::plugins::icingaweb::config {
  File {
    owner   => $icinga::webserver_user,
    group   => $icinga::webserver_group,
    require => Package[$icinga::icingaweb_pkg],
    notify  => [
      Service[$icinga::service_server],
      Service[$icinga::service_webserver],
    ]
  }

  #percona::database { $icinga::icingaweb_dbname:
  #  ensure => present,
  #  notify => Exec['db-initialize'];
  #}

  #percona::user { $icinga::icingaweb_dbuser:
  #  password => $icinga::icingaweb_dbpass,
  #  database => $icinga::icingaweb_dbname,
  #  notify   => Exec['db-initialize'];
  #}

  file {
    $icinga::icingaweb_confdir:
      ensure  => directory;

    $icinga::icingaweb_logdir:
      ensure => directory;

    "${::icinga::icingaweb_confdir}/etc/conf.d/databases.xml":
      ensure   => present,
      content  => template ('icinga/plugins/icingaweb/databases.xml'),
      notify   => Exec['db-initialize'];
  }

  exec {
    'db-initialize':
      path    => $icinga::icingaweb_bindir,
      cwd     => "${::icinga::icingaweb_confdir}/etc",
      command => 'echo y|phing -Dproperties=etc/build.properties db-initialize',
      unless  => "mysqlshow ${::icinga::icingaweb_dbname} | grep cronk",
  }
}

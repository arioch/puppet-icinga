# Class: icinga::reports
#
#   Downloads & installs Icinga Reports into Jasperserver/Tomcat
#
#   Copyright (C) 2014-present Icinga Development Team (http://www.icinga.org/)
#
# Parameters:
#
# Actions:
#
# Requires: mysql, tomcat6, jasperserver, php
#
# Sample Usage:
#
#   include jasperserver
#

class icinga::reports (
  $db_module = 'percona',
  $icinga_reports_version = '1.10.0',
  $icinga_reports_home = $::icinga::params::confdir_server,
  $icinga_availability_function_name = 'icinga_availability',
  $ido_db_name = $::icinga::params::idoutils_dbname,
  $ido_db_username = $::icinga::params::idoutils_dbuser,
  $ido_db_password = $::icinga::params::idoutils_dbpass,
) inherits icinga {

  include tomcat6
  include php

  class {'jasperserver':
    db_module => $db_module,
  }

  case $db_module {
    'percona':   {
      $db_service_name = $percona::service_name
    }
    'mysql':     {
      $db_service_name = 'mysqld'
    }
    default:     { fail('Unsupported DB puppet module') }
  }

  if (!defined(Package['unzip'])) {
    package {'unzip': ensure => 'installed'}
  }

if (!defined(Package['wget'])) {
    package {'wget': ensure => 'installed'}
  }

  $jasper_home = $jasperserver::jasper_home
  $tomcat_home = $jasperserver::tomcat_home
  $tomcat_name = $tomcat6::params::tomcat_name

  # required for icinga-web connector
  php::module{ 'soap': }

  file { $icinga::params::jasper_vhost:
    ensure  => file,
    content => template('icinga/common/jasperserver.conf.erb'),
    notify  => Service[$::icinga::params::service_webserver],
  }

  file { "${icinga_reports_home}/icinga-reports-${icinga_reports_version}":
    ensure => 'directory',
    owner  => $::icinga::params::server_user,
    group  => $::icinga::params::server_group,
  }

  exec { 'get-icinga-reports':
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "/usr/bin/wget -O /tmp/icinga-reports-${icinga_reports_version}.zip https://github.com/Icinga/icinga-reports/archive/v${icinga_reports_version}.zip",
    timeout  => 0,
    provider => 'shell',
    user     => root,
    unless   => "test -d ${icinga_reports_home}/icinga-reports-${icinga_reports_version}",
    require  => Package['wget'],
    notify   => Exec[unzip-icinga-reports],
  }

  exec { 'unzip-icinga-reports':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "unzip -o -q /tmp/icinga-reports-${icinga_reports_version}.zip -d ${icinga_reports_home}",
    require     => Package['unzip'],
    notify      => Exec['install-tomcat-mysql-connector'],
  }

  # use connector provided via package repos, already installed via jasperserver
  exec { 'install-tomcat-mysql-connector':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "cp /usr/share/java/mysql-connector-java.jar ${tomcat_home}/lib/",
    require     => [ Package['mysql-connector-java'], Package['tomcat6'] ],
    notify      => Exec['install-tomcat-mysql-connector-restart-tomcat'],
  }

  exec { 'install-tomcat-mysql-connector-restart-tomcat':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "/etc/init.d/${tomcat_name} restart",
    require     => Exec['install-tomcat-mysql-connector'],
    notify      => Exec['js-import-icinga'],
  }

  exec { 'js-import-icinga':
    refreshonly => true,
    command     => "${jasper_home}/buildomatic/js-import.sh --input-zip ${icinga_reports_home}/icinga-reports-${icinga_reports_version}/reports/icinga/package/js-icinga-reports.zip",
    require     => [ Exec['install-tomcat-mysql-connector'], Package['tomcat6'], Anchor['jasperserver::end'] ],
    cwd         => "${icinga_reports_home}/icinga-reports-${icinga_reports_version}",
    notify      => [Service['tomcat6'], Exec['install-jar-files']],
  }

  file { "${tomcat_home}/webapps/jasperserver/WEB-INF/lib":
    ensure  => 'directory',
    require => [ Anchor['jasperserver::end'], Exec['js-import-icinga'] ]
  }

  exec { 'install-jar-files':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "cp ${icinga_reports_home}/icinga-reports-${icinga_reports_version}/jsp-server/classes/icinga/icinga-reporting.jar ${tomcat_home}/webapps/jasperserver/WEB-INF/lib/",
    require     => File["${tomcat_home}/webapps/jasperserver/WEB-INF/lib"],
    cwd         => "${icinga_reports_home}/icinga-reports-${icinga_reports_version}",
    notify      => [Service['tomcat6'], Exec['install-ido-icinga-availability-sql-function']],
  }

  exec { 'install-ido-icinga-availability-sql-function':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless      => "mysql -u${ido_db_username} -p${ido_db_password} ${ido_db_name} -e 'select name from mysql.proc where name='${icinga_availability_function_name}';'",
    command     => "mysql -u${ido_db_username} -p${ido_db_password} ${ido_db_name} < ${icinga_reports_home}/icinga-reports-${icinga_reports_version}/db/icinga/mysql/availability.sql",
    require     => [ Service[$db_service_name], Exec['install-jar-files'] ]
  }
}

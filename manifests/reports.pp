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
  $icingaReportsVersion = '1.10.0',
  $icingaReportsHome = $::icinga::params::confdir_server,
  $icingaAvailabilityFunctionName = 'icinga_availability',
  $IdoDbName = $::icinga::params::idoutils_dbname,
  $IdoDbUsername = $::icinga::params::idoutils_dbuser,
  $IdoDbPassword = $::icinga::params::idoutils_dbpass,
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

  $jasperHome = $jasperserver::jasperHome
  $tomcatHome = $jasperserver::tomcatHome
  $tomcatName = $tomcat6::params::tomcat_name

  # required for icinga-web connector
  php::module{ 'soap': }

  file { $icinga::params::jasper_vhost:
    ensure  => file,
    content => template('icinga/common/jasperserver.conf.erb'),
    notify  => Service[$::icinga::params::service_webserver],
  }

  file { "${icingaReportsHome}/icinga-reports-${icingaReportsVersion}":
    ensure => 'directory',
    owner  => $::icinga::params::server_user,
    group  => $::icinga::params::server_group,
  }

  exec { 'get-icinga-reports':
    path     => '/bin:/usr/bin:/sbin:/usr/sbin',
    command  => "/usr/bin/wget -O /tmp/icinga-reports-${icingaReportsVersion}.zip https://github.com/Icinga/icinga-reports/archive/v${icingaReportsVersion}.zip",
    timeout  => 0,
    provider => 'shell',
    user     => root,
    unless   => "test -d ${icingaReportsHome}/icinga-reports-${icingaReportsVersion}",
    require  => Package['wget'],
    notify   => Exec[unzip-icinga-reports],
  }

  exec { 'unzip-icinga-reports':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "unzip -o -q /tmp/icinga-reports-${icingaReportsVersion}.zip -d ${icingaReportsHome}",
    require     => Package['unzip'],
    notify      => Exec['install-tomcat-mysql-connector'],
  }

  # use connector provided via package repos, already installed via jasperserver
  exec { 'install-tomcat-mysql-connector':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "cp /usr/share/java/mysql-connector-java.jar ${tomcatHome}/lib/",
    require     => [ Package['mysql-connector-java'], Package['tomcat6'] ],
    notify      => Exec['install-tomcat-mysql-connector-restart-tomcat'],
  }

  exec { 'install-tomcat-mysql-connector-restart-tomcat':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "/etc/init.d/${tomcatName} restart",
    require     => Exec['install-tomcat-mysql-connector'],
    notify      => Exec['js-import-icinga'],
  }

  exec { 'js-import-icinga':
    refreshonly => true,
    command     => "${jasperHome}/buildomatic/js-import.sh --input-zip ${icingaReportsHome}/icinga-reports-${icingaReportsVersion}/reports/icinga/package/js-icinga-reports.zip",
    require     => [ Exec['install-tomcat-mysql-connector'], Package['tomcat6'], Anchor['jasperserver::end'] ],
    cwd         => "${icingaReportsHome}/icinga-reports-${icingaReportsVersion}",
    notify      => [Service['tomcat6'], Exec['install-jar-files']],
  }

  file { "${tomcatHome}/webapps/jasperserver/WEB-INF/lib":
    ensure  => 'directory',
    require => [ Anchor['jasperserver::end'], Exec['js-import-icinga'] ]
  }

  exec { 'install-jar-files':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    command     => "cp ${icingaReportsHome}/icinga-reports-${icingaReportsVersion}/jsp-server/classes/icinga/icinga-reporting.jar ${tomcatHome}/webapps/jasperserver/WEB-INF/lib/",
    require     => File["${tomcatHome}/webapps/jasperserver/WEB-INF/lib"],
    cwd         => "${icingaReportsHome}/icinga-reports-${icingaReportsVersion}",
    notify      => [Service['tomcat6'], Exec['install-ido-icinga-availability-sql-function']],
  }

  exec { 'install-ido-icinga-availability-sql-function':
    refreshonly => true,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless      => "mysql -u${IdoDbUsername} -p${IdoDbPassword} ${IdoDbName} -e 'select name from mysql.proc where name='${icingaAvailabilityFunctionName}';'",
    command     => "mysql -u${IdoDbUsername} -p${IdoDbPassword} ${IdoDbName} < ${icingaReportsHome}/icinga-reports-${icingaReportsVersion}/db/icinga/mysql/availability.sql",
    require     => [ Service[$db_service_name], Exec['install-jar-files'] ]
  }
}

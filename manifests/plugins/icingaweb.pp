# == Class: icinga::plugins::icingaweb
#
# This class provides the Icinga-web plugin.
#
# To use this plugin you need to create a icinga_web database.
# This can be done by using for example the percona puppet-module
# 
# It assumes you have a repository with the icinga-web packages 
# https://wiki.icinga.org/display/howtos/Setting+up+Icinga+Web+on+RHEL
#
# Example percona module nodes/site manifest:
#
#   percona::mysqldb {
#    'icinga_web':
#      user     => 'icinga_web',
#      password => 'icinga_web',
#  }
#
class icinga::plugins::icingaweb {
  if $icinga::server {
    include icinga::plugins::icingaweb::install
    include icinga::plugins::icingaweb::config

    Class['icinga::plugins::icingaweb::install'] ->
    Class['icinga::plugins::icingaweb::config']
  }
}

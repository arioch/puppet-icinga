# == Class: icinga::config::server
#
# This class provides server configuration.
#
class icinga::config::server {
  if $::icinga::server {

    include ::icinga::config::server::common

    case $::operatingsystem {
      'Debian', 'Ubuntu': {
        include icinga::config::server::debian
      }

      'RedHat', 'CentOS', 'Scientific', 'OEL', 'Amazon': {
        include icinga::config::server::redhat
      }

      default: {
        fail 'Operatingsystem not supported.'
      }
    }

    @group { 'nagios':
      ensure  => present,
      members => [
        $::icinga::server_group,
        $::icinga::webserver_group
      ];
    }

    @group { 'icinga':
      ensure  => present,
      members => [
        $::icinga::server_group,
        $::icinga::webserver_group
      ];
    }

    @group { 'icingacmd':
      ensure  => present,
      members => [
        $::icinga::server_group,
        $::icinga::webserver_group
      ];
    }

    realize Group[$::icinga::server_cmd_group]

    include ::icinga::default::hostgroups
    include ::icinga::default::timeperiods
  }
}

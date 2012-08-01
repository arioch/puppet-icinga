class icinga::config::server {
  if $::icinga::server {
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
  }
}

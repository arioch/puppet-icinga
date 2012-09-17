# == Class: icinga::service
#
# This class provides the daemon configuration.
#
class icinga::service {
  Service {
    require => Class['icinga::config'],
  }

  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      if $icinga::client {
        service {
          $icinga::service_client:
            ensure     => $icinga::service_client_ensure,
            enable     => $icinga::service_client_enable,
            hasrestart => $icinga::service_client_hasrestart,
            hasstatus  => $icinga::service_client_hasstatus,
            pattern    => $icinga::service_client_pattern,
        }
      }

      if $icinga::server {
        service {
          $icinga::service_server:
            ensure     => $icinga::service_server_ensure,
            enable     => $icinga::service_server_enable,
            hasrestart => $icinga::service_server_hasrestart,
            hasstatus  => $icinga::service_server_hasstatus,
        }
      }
    }

    'RedHat', 'CentOS', 'Scientific', 'OEL', 'Amazon': {
      if $icinga::client {
        service {
          $icinga::service_client:
            ensure     => $icinga::service_client_ensure,
            enable     => $icinga::service_client_enable,
            hasrestart => $icinga::service_client_hasrestart,
            hasstatus  => $icinga::service_client_hasstatus,
        }
      }

      if $icinga::server {
        service {
          $icinga::service_server:
            ensure     => $icinga::service_server_ensure,
            enable     => $icinga::service_server_enable,
            hasrestart => $icinga::service_server_hasrestart,
            hasstatus  => $icinga::service_server_hasstatus,
        }
      }
    }

    default: {}
  }
}


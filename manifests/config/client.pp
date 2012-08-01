class icinga::config::client {
  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      include icinga::config::client::debian
    }

    'RedHat', 'CentOS', 'Scientific', 'OEL', 'Amazon': {
      include icinga::config::client::redhat
    }

    default: {
      fail "Operatingsystem ${::operatingsystem} not supported."
    }
  }
}

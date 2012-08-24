# == Class: icinga::plugins::idoutils::service
#
# This class provides the idoutils plugin's service.
#
class icinga::plugins::idoutils::service {
  service { $icinga::idoutils_service:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    subscribe => Class['icinga::plugins::idoutils::config'];
  }
}

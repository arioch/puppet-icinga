class icinga::plugins::idoutils::service {
  service { $icinga::idoutils_service:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    subscribe => Class['icinga::plugins::idoutils::config'];
  }
}

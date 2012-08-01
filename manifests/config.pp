class icinga::config {
  include icinga::config::server
  include icinga::config::client

  Class['icinga::config::server'] -> Class['icinga::config::client']
}

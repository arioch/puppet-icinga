# == Class: icinga::config
#
# This class provides the main configuration selector.
#
class icinga::config {
  include icinga::config::server
  include icinga::config::client

  Class['icinga::config::server'] -> Class['icinga::config::client']
}

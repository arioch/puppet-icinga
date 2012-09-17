# == Define: icinga::plugin
#
# This class provides plugin support.
#
define icinga::plugin {
  class {
    "icinga::plugins::${name}":;
  }
}

